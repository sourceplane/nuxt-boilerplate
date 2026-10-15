// The site's identity, written once. The page title reads siteName (app.vue
// hands it to <NuxtWelcome :title>, which sets <title>), and anything added to
// the site later should read it from here too, through useAppConfig(). A site
// made from this one gets it rewritten to its own name when it is created, so
// keep it a literal, on one line.
//
// It lives here, not in an `app/` module: Nuxt 4 takes an `app/` directory as
// the source root, and this app keeps its files at the root.
export default defineAppConfig({
  siteName: "Nuxt Boilerplate",
});
