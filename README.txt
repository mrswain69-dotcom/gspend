HOLIDAY SPLIT - SETUP

What this version does
- One holiday room shared across multiple phones.
- Create/join using an 8-character holiday code.
- Add families/groups and individuals.
- Set individual weights: 100% adult, 50% child, or any custom number.
- Log amount, description, payer and date/time.
- Set the final percentage due from each group.
- Splits each group's liability between its members by weight.
- Calculates individual balances based on what each person actually paid.
- Produces a simple "who pays whom" settlement list.
- Export spending to CSV.
- Installable as a PWA when hosted over HTTPS.

ONE-TIME CLOUD SETUP
1. Create a free Supabase project at supabase.com.
2. In Authentication settings, enable Anonymous Sign-Ins.
3. Open SQL Editor and run SUPABASE_SETUP.sql.
4. This configured build already contains the Project URL and publishable browser key.
5. Host this folder on any static HTTPS host (Cloudflare Pages, Netlify, GitHub Pages, etc.).
6. Open the same hosted app URL on each phone. No Supabase details need to be entered by users.

IMPORTANT
- Do NOT paste the Supabase service-role key into this app. Use only the anon/public key.
- Room access is controlled through anonymous Supabase users plus holiday membership and Row Level Security.
- Names and spending are stored in your Supabase project.

HOW THE SPLIT WORKS
Example: total holiday spend £1,000.
Family A is set to 60% => £600.
Family B is set to 40% => £400.
Family A has two adults at 100 each and one child at 50: total weight 250.
Their £600 share becomes £240 + £240 + £120.
The app then compares those liabilities with what each individual actually paid and generates the transfers needed to settle.
