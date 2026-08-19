GSpend V2

1. Supabase V2 migration is already applied to project warrtwgxgsrmwkdgfjsb.
2. Deploy these files at the root of the existing GitHub/Vercel project.
3. In Supabase Authentication URL Configuration, set Site URL to https://gspend.vercel.app and add https://gspend.vercel.app/** as a Redirect URL so email magic links return to the app.
4. The browser app uses the public Supabase publishable key only.
5. FX rates use the public Frankfurter v2 API; the fetched rate is editable and the saved expense stores a frozen rate/base value.
