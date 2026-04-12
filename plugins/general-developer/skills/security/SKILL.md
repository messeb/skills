---
description: Security best practices — input validation, authentication, encryption, OWASP Top 10, secrets management, API security, and an audit checklist for reviewing code.
---

# Security Best Practices

---

## Input Validation

Input validation is the first line of defense against injection attacks. Always validate and sanitize user input on both client and server sides.

### SQL Injection Prevention

**❌ Vulnerable to SQL Injection:**

```python
# Python
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    cursor.execute(query)
```

```javascript
// JavaScript
const getUserQuery = `SELECT * FROM users WHERE id = ${userId}`;
db.query(getUserQuery);
```

**✅ Safe - Using Parameterized Queries:**

```python
# Python with parameterized queries
def get_user(user_id):
    query = "SELECT * FROM users WHERE id = ?"
    cursor.execute(query, (user_id,))
```

```javascript
// JavaScript with parameterized queries
const getUserQuery = 'SELECT * FROM users WHERE id = ?';
db.query(getUserQuery, [userId]);
```

```java
// Java with PreparedStatement
String query = "SELECT * FROM users WHERE id = ?";
PreparedStatement stmt = connection.prepareStatement(query);
stmt.setInt(1, userId);
ResultSet rs = stmt.executeQuery();
```

### XSS (Cross-Site Scripting) Prevention

**❌ Vulnerable to XSS:**

```javascript
// Directly inserting user content
element.innerHTML = userInput;
document.write(userData);
```

```python
# Flask without escaping
return f"<h1>Welcome {username}</h1>"
```

**✅ Safe - Proper Escaping:**

```javascript
// Use textContent or properly escape
element.textContent = userInput;

// Or use a sanitization library
import DOMPurify from 'dompurify';
element.innerHTML = DOMPurify.sanitize(userInput);
```

```python
# Flask with auto-escaping (default in templates)
return render_template('welcome.html', username=username)

# Or explicit escaping
from markupsafe import escape
return f"<h1>Welcome {escape(username)}</h1>"
```

```jsx
// React (auto-escapes by default)
<h1>Welcome {username}</h1>

// For HTML content, use dangerouslySetInnerHTML carefully
import DOMPurify from 'isomorphic-dompurify';
<div dangerouslySetInnerHTML={{__html: DOMPurify.sanitize(content)}} />
```

### Command Injection Prevention

**❌ Vulnerable to Command Injection:**

```python
# Python
import os
filename = request.args.get('file')
os.system(f"cat {filename}")
```

```javascript
// Node.js
const { exec } = require('child_process');
exec(`ls ${userInput}`);
```

**✅ Safe - Avoid Shell Execution:**

```python
# Python - use safe alternatives
import subprocess
result = subprocess.run(['cat', filename], capture_output=True, check=True)

# Or better, read file directly
with open(filename, 'r') as f:
    content = f.read()
```

```javascript
// Node.js - use safe alternatives
const { execFile } = require('child_process');
execFile('ls', [userInput], (error, stdout) => {
  // Process output
});

// Or use fs module for file operations
const fs = require('fs').promises;
const content = await fs.readFile(filename, 'utf8');
```

### Path Traversal Prevention

**❌ Vulnerable to Path Traversal:**

```python
# Python
filepath = os.path.join('/uploads', request.args.get('file'))
with open(filepath, 'r') as f:
    return f.read()
```

**✅ Safe - Validate and Normalize Paths:**

```python
# Python
import os
from pathlib import Path

UPLOAD_DIR = Path('/uploads').resolve()
filename = request.args.get('file')

# Normalize and validate path
filepath = (UPLOAD_DIR / filename).resolve()
if not filepath.is_relative_to(UPLOAD_DIR):
    raise ValueError("Invalid file path")

with open(filepath, 'r') as f:
    return f.read()
```

```javascript
// Node.js
const path = require('path');
const UPLOAD_DIR = path.resolve('/uploads');

const filepath = path.resolve(UPLOAD_DIR, filename);
if (!filepath.startsWith(UPLOAD_DIR)) {
  throw new Error('Invalid file path');
}
```

---

## Authentication & Authorization

### Password Hashing

**❌ Insecure Password Storage:**

```python
# Never store plaintext passwords
user.password = password

# Never use weak hashing
import hashlib
user.password = hashlib.md5(password.encode()).hexdigest()
```

**✅ Secure Password Hashing:**

```python
# Python - use bcrypt or Argon2
import bcrypt

# Hashing a password
hashed = bcrypt.hashpw(password.encode('utf-8'), bcrypt.gensalt(rounds=12))

# Verifying a password
if bcrypt.checkpw(password.encode('utf-8'), stored_hash):
    # Password correct
```

```python
# Python - using Argon2 (recommended)
from argon2 import PasswordHasher

ph = PasswordHasher()
hashed = ph.hash(password)

# Verification
try:
    ph.verify(hashed, password)
    # Password correct
except:
    # Password incorrect
```

```javascript
// Node.js - using bcrypt
const bcrypt = require('bcrypt');

// Hashing
const saltRounds = 12;
const hashed = await bcrypt.hash(password, saltRounds);

// Verification
const match = await bcrypt.compare(password, hashed);
```

### JWT Best Practices

**❌ Insecure JWT Implementation:**

```javascript
// Using 'none' algorithm
const token = jwt.sign({userId: user.id}, '', {algorithm: 'none'});

// Weak secret
const token = jwt.sign({userId: user.id}, 'secret');

// No expiration
const token = jwt.sign({userId: user.id}, process.env.JWT_SECRET);
```

**✅ Secure JWT Implementation:**

```javascript
// Node.js
const jwt = require('jsonwebtoken');

// Generate token with strong secret and expiration
const token = jwt.sign(
  { userId: user.id, role: user.role },
  process.env.JWT_SECRET, // Use strong, random secret (32+ bytes)
  {
    algorithm: 'HS256',
    expiresIn: '15m', // Short expiration for access tokens
    issuer: 'your-app-name',
    audience: 'your-app-users'
  }
);

// Verify token
try {
  const decoded = jwt.verify(token, process.env.JWT_SECRET, {
    algorithms: ['HS256'],
    issuer: 'your-app-name',
    audience: 'your-app-users'
  });
  // Token valid
} catch (err) {
  // Token invalid or expired
}
```

```python
# Python
import jwt
from datetime import datetime, timedelta

# Generate token
token = jwt.encode(
    {
        'user_id': user.id,
        'role': user.role,
        'exp': datetime.utcnow() + timedelta(minutes=15),
        'iss': 'your-app-name',
        'aud': 'your-app-users'
    },
    os.environ['JWT_SECRET'],
    algorithm='HS256'
)

# Verify token
try:
    decoded = jwt.decode(
        token,
        os.environ['JWT_SECRET'],
        algorithms=['HS256'],
        issuer='your-app-name',
        audience='your-app-users'
    )
except jwt.ExpiredSignatureError:
    # Token expired
except jwt.InvalidTokenError:
    # Token invalid
```

### Session Management

**✅ Secure Session Configuration:**

```javascript
// Express.js
const session = require('express-session');
const RedisStore = require('connect-redis').default;

app.use(session({
  store: new RedisStore({ client: redisClient }),
  secret: process.env.SESSION_SECRET, // Strong random secret
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true, // HTTPS only
    httpOnly: true, // Prevent XSS access
    maxAge: 3600000, // 1 hour
    sameSite: 'strict' // CSRF protection
  }
}));
```

```python
# Flask
from flask import Flask
from flask_session import Session

app = Flask(__name__)
app.config['SESSION_TYPE'] = 'redis'
app.config['SESSION_PERMANENT'] = False
app.config['SESSION_USE_SIGNER'] = True
app.config['SESSION_KEY_PREFIX'] = 'session:'
app.config['SESSION_COOKIE_SECURE'] = True  # HTTPS only
app.config['SESSION_COOKIE_HTTPONLY'] = True  # Prevent XSS
app.config['SESSION_COOKIE_SAMESITE'] = 'Strict'  # CSRF protection
Session(app)
```

### OAuth2 Implementation

**✅ OAuth2 Best Practices:**

```javascript
// Use PKCE (Proof Key for Code Exchange) for public clients
const crypto = require('crypto');

// Generate code verifier and challenge
const codeVerifier = crypto.randomBytes(32).toString('base64url');
const codeChallenge = crypto
  .createHash('sha256')
  .update(codeVerifier)
  .digest('base64url');

// Authorization request
const authUrl = `${authServer}/authorize?` +
  `response_type=code&` +
  `client_id=${clientId}&` +
  `redirect_uri=${redirectUri}&` +
  `scope=${scope}&` +
  `state=${state}&` + // Prevent CSRF
  `code_challenge=${codeChallenge}&` +
  `code_challenge_method=S256`;

// Token exchange
const tokenResponse = await fetch(`${authServer}/token`, {
  method: 'POST',
  headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  body: new URLSearchParams({
    grant_type: 'authorization_code',
    code: authorizationCode,
    redirect_uri: redirectUri,
    client_id: clientId,
    code_verifier: codeVerifier
  })
});
```

### Authorization Patterns

**✅ Role-Based Access Control (RBAC):**

```python
# Python decorator
from functools import wraps
from flask import abort

def require_role(*roles):
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not current_user.is_authenticated:
                abort(401)
            if current_user.role not in roles:
                abort(403)
            return f(*args, **kwargs)
        return decorated_function
    return decorator

@app.route('/admin/users')
@require_role('admin', 'superadmin')
def admin_users():
    # Only admins can access
    pass
```

```javascript
// Express.js middleware
function requireRole(...roles) {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    if (!roles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    next();
  };
}

app.get('/admin/users', requireRole('admin', 'superadmin'), (req, res) => {
  // Only admins can access
});
```

---

## Data Protection & Encryption

### Encryption at Rest

**✅ Encrypting Sensitive Data:**

```python
# Python - using cryptography library
from cryptography.fernet import Fernet

# Generate key (store securely, e.g., in key management service)
key = Fernet.generate_key()
cipher = Fernet(key)

# Encrypt
sensitive_data = "user's SSN or credit card"
encrypted = cipher.encrypt(sensitive_data.encode())

# Decrypt
decrypted = cipher.decrypt(encrypted).decode()
```

```javascript
// Node.js - using crypto module
const crypto = require('crypto');

const algorithm = 'aes-256-gcm';
const key = crypto.randomBytes(32); // Store securely

function encrypt(text) {
  const iv = crypto.randomBytes(16);
  const cipher = crypto.createCipheriv(algorithm, key, iv);

  let encrypted = cipher.update(text, 'utf8', 'hex');
  encrypted += cipher.final('hex');

  const authTag = cipher.getAuthTag();

  return {
    encrypted,
    iv: iv.toString('hex'),
    authTag: authTag.toString('hex')
  };
}

function decrypt(encrypted, iv, authTag) {
  const decipher = crypto.createDecipheriv(
    algorithm,
    key,
    Buffer.from(iv, 'hex')
  );

  decipher.setAuthTag(Buffer.from(authTag, 'hex'));

  let decrypted = decipher.update(encrypted, 'hex', 'utf8');
  decrypted += decipher.final('utf8');

  return decrypted;
}
```

### Encryption in Transit (TLS/HTTPS)

**✅ Enforce HTTPS:**

```javascript
// Express.js - redirect HTTP to HTTPS
app.use((req, res, next) => {
  if (req.header('x-forwarded-proto') !== 'https' && process.env.NODE_ENV === 'production') {
    res.redirect(`https://${req.header('host')}${req.url}`);
  } else {
    next();
  }
});
```

```python
# Flask - enforce HTTPS
from flask_talisman import Talisman

app = Flask(__name__)
Talisman(app, force_https=True)
```

**✅ TLS Configuration (Node.js):**

```javascript
const https = require('https');
const fs = require('fs');

const options = {
  key: fs.readFileSync('private-key.pem'),
  cert: fs.readFileSync('certificate.pem'),
  // Use strong TLS settings
  minVersion: 'TLSv1.3',
  ciphers: 'TLS_AES_256_GCM_SHA384:TLS_AES_128_GCM_SHA256'
};

https.createServer(options, app).listen(443);
```

---

## OWASP Top 10 Vulnerabilities

### A01:2021 – Broken Access Control

**❌ Vulnerable - No Authorization Check:**

```python
@app.route('/api/users/<user_id>/profile', methods=['PUT'])
def update_profile(user_id):
    # Anyone can update any user's profile!
    user = User.query.get(user_id)
    user.update(request.json)
    return jsonify(user)
```

**✅ Secure - Proper Authorization:**

```python
@app.route('/api/users/<user_id>/profile', methods=['PUT'])
@login_required
def update_profile(user_id):
    # Verify user can only update their own profile
    if str(current_user.id) != user_id and not current_user.is_admin:
        abort(403, "Cannot update another user's profile")

    user = User.query.get_or_404(user_id)
    user.update(request.json)
    return jsonify(user)
```

### A02:2021 – Cryptographic Failures

**❌ Vulnerable - Weak Encryption:**

```python
# Using deprecated or weak algorithms
from Crypto.Cipher import DES  # Weak
import hashlib
hash = hashlib.md5(password.encode())  # Weak for passwords
```

**✅ Secure - Strong Encryption:**

```python
# Use modern, secure algorithms
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# AES-256
cipher = Cipher(
    algorithms.AES(key),  # 256-bit key
    modes.GCM(iv),
    backend=default_backend()
)
```

### A03:2021 – Injection

Covered in [Input Validation](#input-validation) section above.

### A04:2021 – Insecure Design

**✅ Secure Design Principles:**

- **Defense in Depth:** Multiple layers of security controls
- **Least Privilege:** Grant minimum necessary permissions
- **Fail Securely:** Default to secure state on errors
- **Secure by Default:** Require opt-in for insecure features

```python
# Example: Secure password reset flow
@app.route('/api/password-reset/request', methods=['POST'])
def request_password_reset():
    email = request.json.get('email')
    user = User.query.filter_by(email=email).first()

    # Don't reveal if email exists (prevent user enumeration)
    # Always show same success message

    if user:
        # Generate secure token
        token = secrets.token_urlsafe(32)

        # Store with expiration
        reset_request = PasswordReset(
            user_id=user.id,
            token_hash=hash_token(token),  # Hash the token
            expires_at=datetime.utcnow() + timedelta(hours=1)
        )
        db.session.add(reset_request)
        db.session.commit()

        # Send email with token
        send_reset_email(user.email, token)

    return jsonify({"message": "If the email exists, a reset link has been sent"})

@app.route('/api/password-reset/confirm', methods=['POST'])
def confirm_password_reset():
    token = request.json.get('token')
    new_password = request.json.get('new_password')

    # Find valid, unexpired reset request
    token_hash = hash_token(token)
    reset = PasswordReset.query.filter_by(
        token_hash=token_hash,
        used=False
    ).first()

    if not reset or reset.expires_at < datetime.utcnow():
        abort(400, "Invalid or expired token")

    # Update password
    user = User.query.get(reset.user_id)
    user.set_password(new_password)

    # Mark token as used
    reset.used = True
    db.session.commit()

    # Invalidate all sessions
    user.invalidate_sessions()

    return jsonify({"message": "Password reset successful"})
```

### A05:2021 – Security Misconfiguration

**❌ Common Misconfigurations:**

```python
# Debug mode in production
app.config['DEBUG'] = True

# Verbose error messages
app.config['PROPAGATE_EXCEPTIONS'] = True

# Default credentials
DATABASE_URL = 'postgresql://admin:admin@localhost/db'
```

**✅ Secure Configuration:**

```python
# Use environment-specific settings
app.config['DEBUG'] = os.getenv('FLASK_ENV') == 'development'

# Custom error handlers
@app.errorhandler(Exception)
def handle_error(e):
    if app.config['DEBUG']:
        raise e
    # Log error internally
    logger.error(f"Error: {e}")
    # Return generic message to user
    return jsonify({"error": "Internal server error"}), 500

# Use environment variables
DATABASE_URL = os.getenv('DATABASE_URL')
if not DATABASE_URL:
    raise ValueError("DATABASE_URL must be set")
```

### A06:2021 – Vulnerable Components

Covered in [Dependency Security](#dependency-security) section below.

### A07:2021 – Authentication Failures

Covered in [Authentication & Authorization](#authentication--authorization) section above.

**✅ Additional: Rate Limiting for Login:**

```python
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

@app.route('/api/login', methods=['POST'])
@limiter.limit("5 per minute")
def login():
    # Login logic
    pass
```

### A08:2021 – Software and Data Integrity Failures

**✅ Verify Package Integrity:**

```bash
# Python - use hash checking
pip install --require-hashes -r requirements.txt

# requirements.txt with hashes
Flask==2.3.0 \
    --hash=sha256:abc123...
```

```json
// package.json - use exact versions
{
  "dependencies": {
    "express": "4.18.2"  // Not "^4.18.2"
  }
}
```

**✅ Code Signing and Verification:**

```bash
# Git commit signing
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY
```

### A09:2021 – Security Logging Failures

Log authentication attempts, access denials, and sensitive operations. Never log passwords, tokens, or other secrets. See [Logging & Monitoring](#logging--monitoring) for a full implementation.

### A10:2021 – Server-Side Request Forgery (SSRF)

**❌ Vulnerable to SSRF:**

```python
@app.route('/api/fetch-url')
def fetch_url():
    url = request.args.get('url')
    response = requests.get(url)  # Attacker can access internal services
    return response.content
```

**✅ Protected Against SSRF:**

```python
import ipaddress
from urllib.parse import urlparse

ALLOWED_DOMAINS = ['api.example.com', 'cdn.example.com']

def is_safe_url(url):
    try:
        parsed = urlparse(url)

        # Only allow HTTP(S)
        if parsed.scheme not in ['http', 'https']:
            return False

        # Check domain whitelist
        if parsed.hostname not in ALLOWED_DOMAINS:
            return False

        # Prevent access to private IP ranges
        ip = ipaddress.ip_address(socket.gethostbyname(parsed.hostname))
        if ip.is_private or ip.is_loopback or ip.is_link_local:
            return False

        return True
    except:
        return False

@app.route('/api/fetch-url')
def fetch_url():
    url = request.args.get('url')

    if not is_safe_url(url):
        abort(400, "Invalid URL")

    response = requests.get(url, timeout=5)
    return response.content
```

---

## Secrets Management

### Environment Variables

**❌ Hardcoded Secrets:**

```python
# Never commit secrets to code
API_KEY = "sk-abc123xyz789"
DATABASE_URL = "postgresql://user:password@localhost/db"
```

**✅ Use Environment Variables:**

```python
# Python
import os
from dotenv import load_dotenv

load_dotenv()  # Load from .env file in development

API_KEY = os.getenv('API_KEY')
if not API_KEY:
    raise ValueError("API_KEY environment variable not set")

DATABASE_URL = os.getenv('DATABASE_URL')
```

**.env file (never commit this):**

```text
API_KEY=sk-abc123xyz789
DATABASE_URL=postgresql://user:password@localhost/db
```

**.gitignore:**

```text
.env
.env.local
.env.*.local
```

### Key Rotation

**✅ Implement Key Rotation:**

```python
class KeyManager:
    def __init__(self):
        self.current_key = os.getenv('ENCRYPTION_KEY_CURRENT')
        self.previous_keys = [
            os.getenv('ENCRYPTION_KEY_PREVIOUS_1'),
            os.getenv('ENCRYPTION_KEY_PREVIOUS_2')
        ]

    def encrypt(self, data):
        # Always encrypt with current key
        return encrypt_with_key(data, self.current_key)

    def decrypt(self, encrypted_data):
        # Try current key first
        try:
            return decrypt_with_key(encrypted_data, self.current_key)
        except DecryptionError:
            # Try previous keys
            for key in self.previous_keys:
                try:
                    # Decrypt with old key and re-encrypt with current
                    data = decrypt_with_key(encrypted_data, key)
                    return self.encrypt(data)  # Re-encrypt
                except DecryptionError:
                    continue
            raise ValueError("Unable to decrypt data")
```

### Secret Stores

**✅ Use Secret Management Services:**

```python
# AWS Secrets Manager
import boto3

def get_secret(secret_name):
    client = boto3.client('secretsmanager')
    response = client.get_secret_value(SecretId=secret_name)
    return response['SecretString']

DATABASE_PASSWORD = get_secret('prod/database/password')
```

```python
# HashiCorp Vault
import hvac

client = hvac.Client(url='https://vault.example.com')
client.token = os.getenv('VAULT_TOKEN')

secret = client.secrets.kv.v2.read_secret_version(path='database/config')
DATABASE_PASSWORD = secret['data']['data']['password']
```

---

## API Security

### Rate Limiting

**✅ Implement Rate Limiting:**

```javascript
// Express.js
const rateLimit = require('express-rate-limit');

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP',
  standardHeaders: true,
  legacyHeaders: false,
});

app.use('/api/', limiter);

// Stricter limits for sensitive endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  skipSuccessfulRequests: true
});

app.post('/api/login', authLimiter, loginHandler);
```

### CORS Configuration

**❌ Insecure CORS:**

```javascript
// Allow all origins
app.use(cors({ origin: '*' }));
```

**✅ Secure CORS:**

```javascript
const cors = require('cors');

const corsOptions = {
  origin: function (origin, callback) {
    const allowedOrigins = [
      'https://example.com',
      'https://app.example.com'
    ];

    if (!origin || allowedOrigins.includes(origin)) {
      callback(null, true);
    } else {
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  maxAge: 86400 // 24 hours
};

app.use(cors(corsOptions));
```

### CSRF Protection

**✅ CSRF Token Implementation:**

```javascript
// Express.js
const csrf = require('csurf');
const csrfProtection = csrf({ cookie: true });

app.use(csrfProtection);

// Provide CSRF token to client
app.get('/api/csrf-token', (req, res) => {
  res.json({ csrfToken: req.csrfToken() });
});

// Require CSRF token for state-changing operations
app.post('/api/data', csrfProtection, (req, res) => {
  // Process request
});
```

```python
# Flask
from flask_wtf.csrf import CSRFProtect

csrf = CSRFProtect(app)

# Exempt API endpoints if using token auth
@csrf.exempt
@app.route('/api/login', methods=['POST'])
def login():
    # Use other authentication
    pass
```

### API Authentication

**✅ Bearer Token Authentication:**

```javascript
function authenticateToken(req, res, next) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Invalid token' });
    }
    req.user = user;
    next();
  });
}

app.get('/api/protected', authenticateToken, (req, res) => {
  res.json({ data: 'Protected data', user: req.user });
});
```

---

## Dependency Security

### Package Auditing

**✅ Regular Security Audits:**

```bash
# Node.js
npm audit
npm audit fix

# Python
pip-audit
# or
safety check

# Ruby
bundle audit
```

### Version Pinning

**✅ Lock File Usage:**

```bash
# Node.js - commit package-lock.json
npm ci  # Use in CI/CD for reproducible builds

# Python - use requirements.txt with versions
pip freeze > requirements.txt

# Or use pipenv/poetry for lock files
pipenv lock
poetry lock
```

### Automated Dependency Updates

**✅ Dependabot Configuration (.github/dependabot.yml):**

```yaml
version: 2
updates:
  - package-ecosystem: "npm"
    directory: "/"
    schedule:
      interval: "weekly"
    open-pull-requests-limit: 10

  - package-ecosystem: "pip"
    directory: "/"
    schedule:
      interval: "weekly"
```

---

## Security Headers

**✅ Essential Security Headers:**

```javascript
// Express.js - using Helmet
const helmet = require('helmet');

app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: ["'self'", "'unsafe-inline'"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
    },
  },
  hsts: {
    maxAge: 31536000,
    includeSubDomains: true,
    preload: true
  },
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' },
  xssFilter: true,
  noSniff: true,
  ieNoOpen: true,
  hidePoweredBy: true
}));
```

```python
# Flask - using Flask-Talisman
from flask_talisman import Talisman

csp = {
    'default-src': "'self'",
    'script-src': ["'self'", "'unsafe-inline'"],
    'style-src': ["'self'", "'unsafe-inline'"],
}

Talisman(app, content_security_policy=csp, force_https=True)
```

---

## Logging & Monitoring

**✅ Security Event Logging:**

```python
import logging
import json
from datetime import datetime

class SecurityLogger:
    def __init__(self):
        self.logger = logging.getLogger('security')
        handler = logging.FileHandler('security.log')
        handler.setFormatter(logging.Formatter('%(message)s'))
        self.logger.addHandler(handler)
        self.logger.setLevel(logging.INFO)

    def log_event(self, event_type, user_id=None, ip_address=None, details=None):
        event = {
            'timestamp': datetime.utcnow().isoformat(),
            'event_type': event_type,
            'user_id': user_id,
            'ip_address': ip_address,
            'details': details
        }
        self.logger.info(json.dumps(event))

security_logger = SecurityLogger()

# Log security events
@app.route('/api/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')

    user = authenticate(username, password)

    if user:
        security_logger.log_event(
            'login_success',
            user_id=user.id,
            ip_address=request.remote_addr,
            details={'username': username}
        )
    else:
        security_logger.log_event(
            'login_failure',
            ip_address=request.remote_addr,
            details={'username': username, 'reason': 'invalid_credentials'}
        )

    # Continue with login logic
```

---

## Audit Checklist

When reviewing a codebase for security issues:

### Input & Output

- [ ] All user input validated on server side
- [ ] SQL queries use parameterized statements
- [ ] HTML output properly escaped
- [ ] File paths validated against traversal
- [ ] Command execution avoided or properly sanitized

### Authentication & Authorization

- [ ] Passwords hashed with bcrypt/Argon2 (12+ rounds)
- [ ] JWT tokens have expiration (15min for access, 7d for refresh)
- [ ] Session cookies have secure, httpOnly, sameSite flags
- [ ] Rate limiting on authentication endpoints
- [ ] Authorization checked for every protected resource
- [ ] Multi-factor authentication supported for sensitive operations

### Data Protection

- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced in production
- [ ] TLS 1.3 used (minimum TLS 1.2)
- [ ] Strong encryption algorithms (AES-256, RSA-2048+)
- [ ] Database credentials encrypted
- [ ] Backup data encrypted

### API Security

- [ ] CORS configured with specific origins
- [ ] CSRF protection enabled for state-changing operations
- [ ] Rate limiting configured
- [ ] API authentication required
- [ ] Input validation on all endpoints
- [ ] Error messages don't leak sensitive information

### Secrets Management Checklist

- [ ] No hardcoded secrets in code
- [ ] Environment variables used for configuration
- [ ] .env files in .gitignore
- [ ] Secret rotation mechanism in place
- [ ] Production secrets in secure vault

### Dependencies

- [ ] Dependencies regularly audited (npm audit, pip-audit)
- [ ] Versions pinned in lock files
- [ ] Automated dependency updates configured
- [ ] Only necessary dependencies included

### Security Headers Checklist

- [ ] Content-Security-Policy configured
- [ ] Strict-Transport-Security enabled
- [ ] X-Content-Type-Options: nosniff
- [ ] X-Frame-Options: DENY or SAMEORIGIN
- [ ] Referrer-Policy configured

### Logging & Monitoring Checklist

- [ ] Security events logged (login attempts, access denials)
- [ ] Sensitive data excluded from logs
- [ ] Log rotation configured
- [ ] Monitoring alerts for suspicious activity
- [ ] Audit trail for sensitive operations
