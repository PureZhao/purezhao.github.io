(function () {
    var script = document.currentScript;
    var base = '';

    if (script && script.src) {
        var pathname = new URL(script.src, window.location.href).pathname;
        var marker = '/js/site.js';
        var idx = pathname.lastIndexOf(marker);
        if (idx >= 0) {
            base = pathname.slice(0, idx);
        }
    }

    window.SITE_BASE = base;

    window.sitePath = function (path) {
        var normalized = String(path).replace(/\\/g, '/').replace(/^\/+/, '');
        return base + '/' + normalized;
    };

    window.resolveAssetUrl = function (url) {
        if (!url || /^https?:\/\//i.test(url)) {
            return url;
        }
        if (url.charAt(0) === '/') {
            return base + url;
        }
        return sitePath(url.replace(/^(\.\.\/)+/, ''));
    };
})();
