module.exports = {
  title: 'Web 前端',
  description: 'jiyijun.github.io',
  plugins: ['@vuepress/back-to-top'],
  themeConfig: {
    logo: '/logo.svg',
    displayAllHeaders: true,
    nav: [
      { text: 'Github', link: 'https://github.com/yijunJi?tab=repositories' },
    ],
    sidebar: [
      {
        title: '浏览器',
        path: '/chrome/'
      },
      {
        title: 'Javascript',
        path: '/js/',
      },
      {
        title: 'React',
        path: '/react/'
      }
    ]
  },
  markdown: {
    lineNumbers: true
  }
}
