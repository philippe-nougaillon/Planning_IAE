const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './public/*.html',
    './app/**/*.{rb,erb,haml,html,slim,js}',
    './lib/**/*.rb',
    './config/**/*.rb',
  ],
  safelist: [
    // STAGING_COLOR_MODE injects a bg-* class via ENV; the scanner can't see it
    { pattern: /^bg-(red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose|slate|gray|zinc|neutral|stone)-(50|100|200|300|400|500|600|700|800|900)$/ },
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ['Inter var', ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: []
}
