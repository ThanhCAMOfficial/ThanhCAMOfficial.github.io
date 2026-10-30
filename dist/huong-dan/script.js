// Nút "Sao chép" cho mọi khung code có .copy
document.querySelectorAll('.code-box .copy').forEach(btn => {
  btn.addEventListener('click', async () => {
    const pre = btn.closest('.code-box').querySelector('pre');
    try {
      await navigator.clipboard.writeText(pre.innerText);
      btn.textContent = 'Đã chép';
    } catch {
      const r = document.createRange(); r.selectNodeContents(pre);
      const s = getSelection(); s.removeAllRanges(); s.addRange(r);
      btn.textContent = 'Ctrl+C';
    }
    setTimeout(() => { btn.textContent = 'Sao chép'; }, 1600);
  });
});
