# Composable Bridge

Composables are the presentation boundary between Vue reactivity and the domain/application layer. They own three responsibilities:

1. **Create** the infrastructure objects the use case needs
2. **Translate** Vue reactive state → plain input DTOs → `execute()`
3. **Map** `Result` back to Vue reactive state

Pages and components never touch use cases directly.

## Form Submission Composable

```typescript
// composables/useRegistrationForm.ts
import { reactive, ref } from 'vue'
import { HttpUserRepository } from '../infrastructure/client/HttpUserRepository'
import { RegisterUserUseCase } from '../application/use-cases/RegisterUserUseCase'
import { UserRegistrationPolicy } from '../domain/UserRegistrationPolicy'

export function useRegistrationForm() {
  const repository = new HttpUserRepository()
  const policy     = new UserRegistrationPolicy()
  const useCase    = new RegisterUserUseCase(repository, policy)

  const form   = reactive({ username: '', email: '', password: '' })
  const errors = reactive<{ username?: string; email?: string; password?: string }>({})
  const status = ref<'idle' | 'loading' | 'success' | 'error'>('idle')

  async function submit() {
    if (status.value === 'loading') return   // guard against double-submit

    status.value     = 'loading'
    errors.username  = undefined
    errors.email     = undefined
    errors.password  = undefined

    const result = await useCase.execute({ ...form })   // plain DTO, no Vue types

    if (result.ok) {
      status.value = 'success'
      return
    }

    if (result.fieldErrors) {
      errors.username = result.fieldErrors.username
      errors.email    = result.fieldErrors.email
      errors.password = result.fieldErrors.password
      status.value    = 'idle'
    } else {
      status.value = 'error'
    }
  }

  return { form, errors, status, submit }
}
```

## Live Validation Composable

Because value objects are pure functions, you can call `VO.create()` inside a `computed()` for zero-latency UI feedback:

```typescript
// composables/useUsernameLiveValidation.ts
import { computed } from 'vue'
import type { Ref } from 'vue'
import { Username } from '../domain/Username'

export function useUsernameLiveValidation(username: Ref<string>) {
  const result    = computed(() => Username.create(username.value))
  const charCount = computed(() => username.value.trim().length)

  const status = computed((): 'empty' | 'tooShort' | 'tooLong' | 'invalidCharacters' | 'valid' => {
    if (result.value.ok) return 'valid'
    return result.value.error.type
  })

  const hint = computed((): string => {
    if (result.value.ok) return `${charCount.value} characters`
    const err = result.value.error
    if (err.type === 'tooShort')          return `${err.delta} more characters needed`
    if (err.type === 'tooLong')           return `${err.delta} characters over limit`
    if (err.type === 'invalidCharacters') return 'Only letters, numbers, _ and - allowed'
    return 'Name is required'
  })

  return { charCount, status, hint }
}
```

No server round-trip — domain logic runs synchronously in the browser.

## Composing Both in a Page

```vue
<!-- pages/register.vue -->
<script setup lang="ts">
import { toRef } from 'vue'

const { form, errors, status, submit } = useRegistrationForm()
const usernameRef = toRef(form, 'username')
const { charCount, status: usernameStatus, hint } = useUsernameLiveValidation(usernameRef)
</script>
```

`toRef(form, 'username')` creates a reactive ref from a reactive object property — required because `useUsernameLiveValidation` expects a `Ref<string>`.

## Rules

- `reactive`, `ref`, `computed` live here — not in domain or application
- No business logic — validation rules stay in the domain
- No `$fetch` calls — those belong in the infrastructure adapter
- The import chain must always be: `domain/` → `composables/` → `components/`
- **Components never call domain VOs directly** — create a dedicated composable instead

```
// WRONG — VO called inside a component
import { Username } from '~/domain/Username'
const validation = computed(() => Username.create(props.modelValue))

// CORRECT — VO call lives in a composable
import { useUsernameLiveValidation } from '~/composables/useUsernameLiveValidation'
const modelValueRef = computed(() => props.modelValue)
const { status, hint } = useUsernameLiveValidation(modelValueRef)
```

## When to Split Into Multiple Composables

One composable per user action (matches one use case). Live validation for a single field is its own composable — it is a distinct, reusable concern and independent of form submission.
