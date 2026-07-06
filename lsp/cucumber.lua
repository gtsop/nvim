return {
  cmd = { "cucumber-language-server", "--stdio" },
  filetypes = { "gherkin" },
  root_markers = {
    "package.json",
    ".git",
  },
  settings = {
    cucumber = {
      features = {
        "cypress/e2e/**/*.feature",
      },
      glue = {
        "cypress/e2e/**/*.js",
        "cypress/e2e/**/*.ts",
        "cypress/support/**/*.js",
        "cypress/support/**/*.ts",
      },
    },
  },
}
