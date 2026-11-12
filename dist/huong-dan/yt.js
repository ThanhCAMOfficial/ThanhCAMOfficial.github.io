// Bấm ảnh mới tải video YouTube (trang nhẹ, không cookie trước khi xem)
document.querySelectorAll('.yt[data-id]').forEach(b => {
  b.style.backgroundImage = `url(https://i.ytimg.com/vi/${b.dataset.id}/hqdefault.jpg)`;
  b.addEventListener('click', () => {
    const box = document.createElement('div');
    box.className = 'yt';
    const f = document.createElement('iframe');
    f.src = `https://www.youtube-nocookie.com/embed/${b.dataset.id}?autoplay=1&rel=0`;
    f.title = b.getAttribute('aria-label') || 'Video';
    f.allow = 'autoplay; encrypted-media; picture-in-picture';
    f.allowFullscreen = true;
    box.appendChild(f);
    b.replaceWith(box);
  }, { once: true });
});
