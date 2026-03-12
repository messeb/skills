---
description: Vite configuration best practices — plugins, environment variables, chunking strategy, performance, SSR mode, and build optimization.
---

# Vite Configuration Best Practices

## Core Concepts

Vite is a build tool with two modes:
- **Dev**: native ES modules in the browser + HMR via esbuild
- **Build**: Rollup bundler producing optimized production output

Understanding this split is key: dev configuration affects DX, build configuration affects production performance.

---

## Base Configuration

```ts
// vite.config.ts
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import { fileURLToPath, URL } from 'node:url'

export default defineConfig(({ command, mode }) => {
  const env = loadEnv(mode, process.cwd(), '')

  return {
    plugins: [vue(), vueJsx()],

    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
        '~': fileURLToPath(new URL('./src', import.meta.url)),
      },
    },

    server: {
      port: 3000,
      strictPort: true,
      proxy: {
        '/api': {
          target: env.VITE_API_URL ?? 'http://localhost:8080',
          changeOrigin: true,
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    },

    preview: {
      port: 4173,
    },
  }
})
```

---

## Environment Variables

Vite exposes only variables prefixed with `VITE_` to client-side code. This is a security boundary.

```
.env                # loaded always
.env.local          # loaded always, git-ignored
.env.development    # loaded in dev mode only
.env.production     # loaded in production build only
.env.staging        # loaded when VITE_MODE=staging
```

```bash
# .env.development
VITE_API_URL=http://localhost:8080
VITE_ENABLE_DEVTOOLS=true

# .env.production
VITE_API_URL=https://api.example.com
VITE_ENABLE_DEVTOOLS=false

# Never prefix secrets — they'll be in the bundle:
DATABASE_URL=postgres://...   # server-side only, NOT exposed
STRIPE_SECRET=sk_...          # server-side only, NOT exposed
```

### Type-safe env variables

```ts
// env.d.ts
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string
  readonly VITE_ENABLE_DEVTOOLS: string
  readonly VITE_SENTRY_DSN: string
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
```

```ts
// Usage
const apiUrl = import.meta.env.VITE_API_URL
const isDev = import.meta.env.DEV
const isProd = import.meta.env.PROD
```

---

## Build Optimization

### Manual chunk splitting

```ts
export default defineConfig({
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          // Vendor chunks — stable hash, long-term caching
          'vendor-vue': ['vue', 'vue-router', 'pinia'],
          'vendor-ui': ['@headlessui/vue', '@heroicons/vue'],
          'vendor-utils': ['date-fns', 'zod', 'lodash-es'],
          // Heavy, infrequently changing libraries
          'vendor-charts': ['chart.js', 'vue-chartjs'],
        },
      },
    },
    // Increase warning threshold (default 500kb)
    chunkSizeWarningLimit: 800,
  },
})
```

### Dynamic chunk splitting with regex

```ts
manualChunks(id) {
  if (id.includes('node_modules')) {
    // Split each node_modules package into its own chunk
    const pkg = id.match(/node_modules\/([^/]+)/)?.[1]
    if (pkg) return `vendor-${pkg}`
  }
  // Split by feature
  if (id.includes('src/features/admin')) return 'feature-admin'
  if (id.includes('src/features/reports')) return 'feature-reports'
}
```

### Target modern browsers

```ts
export default defineConfig({
  build: {
    target: 'es2020',        // drop IE11 support, smaller output
    minify: 'esbuild',       // faster than terser, similar output
    sourcemap: process.env.NODE_ENV !== 'production',
    cssCodeSplit: true,      // separate CSS per chunk
    assetsInlineLimit: 4096, // inline assets < 4kb as base64
  },
})
```

---

## Essential Plugins

### Auto-import (reduce boilerplate)

```ts
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'

export default defineConfig({
  plugins: [
    AutoImport({
      imports: ['vue', 'vue-router', 'pinia', '@vueuse/core'],
      dirs: ['src/composables', 'src/stores'],
      dts: 'src/auto-imports.d.ts',
    }),
    Components({
      dirs: ['src/components'],
      dts: 'src/components.d.ts',
    }),
  ],
})
```

### Bundle analysis

```bash
pnpm add -D rollup-plugin-visualizer
```

```ts
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig(({ mode }) => ({
  plugins: [
    // Only include in analyze mode: ANALYZE=true vite build
    process.env.ANALYZE && visualizer({
      open: true,
      filename: 'dist/stats.html',
      gzipSize: true,
      brotliSize: true,
    }),
  ],
}))
```

### Compression

```ts
import viteCompression from 'vite-plugin-compression'

plugins: [
  viteCompression({ algorithm: 'gzip' }),
  viteCompression({ algorithm: 'brotliCompress', ext: '.br' }),
]
```

### SVG as Vue components

```ts
import svgLoader from 'vite-svg-loader'

plugins: [
  svgLoader({ defaultImport: 'component' }),
]
```

---

## CSS Configuration

```ts
export default defineConfig({
  css: {
    preprocessorOptions: {
      scss: {
        // Auto-inject design tokens into every SCSS file
        additionalData: `@use "@/assets/styles/tokens" as *;`,
      },
    },
    modules: {
      localsConvention: 'camelCase',
      generateScopedName: '[name]__[local]__[hash:base64:5]',
    },
  },
})
```

---

## Library Mode

When building a component library instead of an app:

```ts
import { resolve } from 'node:path'

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'MyComponentLib',
      formats: ['es', 'cjs'],
      fileName: (format) => `my-lib.${format}.js`,
    },
    rollupOptions: {
      // Externalize peer dependencies
      external: ['vue'],
      output: {
        globals: { vue: 'Vue' },
        exports: 'named',
      },
    },
  },
})
```

---

## SSR Mode

```ts
export default defineConfig({
  ssr: {
    // Externalize Node.js-only packages (not bundled for browser)
    external: ['pg', 'fs', 'path'],
    // Force-bundle packages with ESM issues
    noExternal: ['some-esm-package'],
  },
})
```

---

## Dev Performance

```ts
export default defineConfig({
  optimizeDeps: {
    // Pre-bundle commonly used deps to speed up cold start
    include: ['vue', 'pinia', 'vue-router', 'axios', '@vueuse/core'],
    // Exclude packages that don't need pre-bundling
    exclude: ['your-local-linked-package'],
  },
  server: {
    warmup: {
      // Pre-transform files on server start (reduces first-page load time)
      clientFiles: ['./src/main.ts', './src/App.vue'],
    },
  },
})
```

---

## Audit Checklist

1. **Single vendor chunk containing everything** — one massive `vendor.js` with all dependencies; cache is busted on any dep update; split by logical group
2. **`VITE_` prefix on secrets** — API keys, tokens, or passwords prefixed with `VITE_` are embedded in the client bundle and visible to anyone
3. **No chunk splitting for large features** — admin panel, reporting module, or map component bundled in the main entry; lazy-load with dynamic `import()`
4. **`build.target: 'es5'`** — unnecessary polyfills doubling bundle size; modern browsers (2020+) support ES2020+ natively
5. **Missing `optimizeDeps.include`** — large dependencies like `lodash`, `moment`, or `antd` not pre-bundled; slow cold starts in dev
6. **Source maps in production** — `sourcemap: true` in production builds exposes source code; use `'hidden'` for error tracking without exposure
7. **Unused plugins left in config** — plugins with significant overhead (e.g., legacy plugin) included in dev builds unnecessarily
8. **No `preview` port configured** — `vite preview` uses a random port; set `preview.port` to match the production proxy configuration
