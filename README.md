# Mfalme Palace API

## Deploy to Render (production callback URL)

This repo includes `render.yaml` for quick deployment.

### 1) Push this backend to GitHub
Render deploys from a Git repository.

### 2) Create service in Render
- In Render: **New +** -> **Blueprint**
- Select this repository and deploy.
- Render will create:
  - Web service: `mfalme-palace-api`
  - PostgreSQL database: `mfalme-palace-db`

### 3) Run database setup once deployed
Use Render Shell for the web service:
- `bundle exec rails db:migrate`
- `bundle exec rails db:seed`

### 4) Set required env vars in Render
Set these in the web service Environment tab:
- `MPESA_BASE_URL` (`https://sandbox.safaricom.co.ke` or production URL)
- `MPESA_CONSUMER_KEY`
- `MPESA_CONSUMER_SECRET`
- `MPESA_SHORTCODE`
- `MPESA_PASSKEY`
- `MPESA_CALLBACK_URL`

Admin bootstrap (optional):
- `ADMIN_EMAIL`
- `ADMIN_PASSWORD`
- `ADMIN_NAME`
- `ADMIN_PHONE`

### 5) Callback URL to register in Safaricom/Daraja
Once deployed, your callback should be:

`https://<your-render-service>.onrender.com/payments/webhook/mpesa`

Example:
`https://mfalme-palace-api.onrender.com/payments/webhook/mpesa`
