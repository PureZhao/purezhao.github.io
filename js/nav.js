const NAV_ITEMS = [
    { label: '首页', href: 'index.html' },
    { label: '服务器列表', href: 'pages/servers.html' },
    { label: '地图列表', href: 'pages/maps.html' },
    { label: '插件开发教程', href: 'pages/tutorial.html' },
    { label: '封禁列表', href: 'pages/bans.html' },
    { label: '图片画廊', href: 'pages/gallery.html' },
    { label: '插件答疑QQ群：暂无' },
];

(function renderNav() {
    const nav = document.getElementById('site-nav');
    if (!nav) return;

    const ul = document.createElement('ul');
    ul.className = 'nav-links';

    NAV_ITEMS.forEach(function (item) {
        const li = document.createElement('li');
        const a = document.createElement('a');
        if (item.href) {
            a.href = sitePath(item.href);
        }
        a.textContent = item.label;
        li.appendChild(a);
        ul.appendChild(li);
    });

    nav.appendChild(ul);
})();
