/* Justice4U shared/script.js — Landing page interactions only (≤300 lines) */
'use strict';

// ─── Navigation ──────────────────────────────────────────────────────────────
function initNavigation() {
  const nav = document.querySelector('.nav, nav, header');
  if (!nav) return;
  let lastY = 0;
  window.addEventListener('scroll', () => {
    const y = window.scrollY;
    nav.classList.toggle('scrolled', y > 50);
    nav.classList.toggle('nav-hidden', y > lastY + 5 && y > 200);
    lastY = y;
  }, { passive: true });
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const t = document.querySelector(a.getAttribute('href'));
      if (t) { e.preventDefault(); t.scrollIntoView({ behavior: 'smooth', block: 'start' }); }
    });
  });
}

// ─── Scroll Reveal ───────────────────────────────────────────────────────────
function initScrollReveal() {
  if (!('IntersectionObserver' in window)) return;
  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (e.isIntersecting) { e.target.classList.add('revealed'); io.unobserve(e.target); }
    });
  }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
  document.querySelectorAll('.reveal, [data-reveal]').forEach(el => io.observe(el));
}

// ─── Counter Animations ──────────────────────────────────────────────────────
function initCounterAnimations() {
  if (!('IntersectionObserver' in window)) return;
  const io = new IntersectionObserver((entries) => {
    entries.forEach(e => {
      if (!e.isIntersecting) return;
      const el = e.target;
      const target = parseInt(el.dataset.count || el.textContent.replace(/\D/g, ''), 10);
      if (isNaN(target)) return;
      let start = 0;
      const duration = 1500;
      const step = (timestamp) => {
        if (!start) start = timestamp;
        const progress = Math.min((timestamp - start) / duration, 1);
        el.textContent = Math.floor(progress * target).toLocaleString() + (el.dataset.suffix || '');
        if (progress < 1) requestAnimationFrame(step);
      };
      requestAnimationFrame(step);
      io.unobserve(el);
    });
  }, { threshold: 0.5 });
  document.querySelectorAll('[data-count]').forEach(el => io.observe(el));
}

// ─── Typing Effect ───────────────────────────────────────────────────────────
function initTypingEffect() {
  const el = document.querySelector('[data-typing]');
  if (!el) return;
  const words = (el.dataset.typing || '').split(',').map(s => s.trim()).filter(Boolean);
  if (!words.length) return;
  let wi = 0, ci = 0, deleting = false;
  const tick = () => {
    const word = words[wi];
    if (deleting) { el.textContent = word.slice(0, --ci); }
    else { el.textContent = word.slice(0, ++ci); }
    if (!deleting && ci === word.length) { deleting = true; return setTimeout(tick, 1800); }
    if (deleting && ci === 0) { deleting = false; wi = (wi + 1) % words.length; }
    setTimeout(tick, deleting ? 50 : 100);
  };
  tick();
}

// ─── Scroll Progress Bar ─────────────────────────────────────────────────────
function initScrollProgress() {
  const bar = document.querySelector('.scroll-progress, #scrollProgress');
  if (!bar) return;
  window.addEventListener('scroll', () => {
    const h = document.documentElement;
    const pct = (h.scrollTop / (h.scrollHeight - h.clientHeight)) * 100;
    bar.style.width = pct + '%';
  }, { passive: true });
}

// ─── Form Validation ─────────────────────────────────────────────────────────
function initFormValidation() {
  document.querySelectorAll('form[data-validate]').forEach(form => {
    form.addEventListener('submit', e => {
      let valid = true;
      form.querySelectorAll('[required]').forEach(field => {
        const err = field.parentElement.querySelector('.field-error');
        if (!field.value.trim()) {
          valid = false; field.classList.add('is-invalid');
          if (err) err.textContent = field.dataset.error || 'This field is required.';
        } else {
          field.classList.remove('is-invalid');
          if (err) err.textContent = '';
        }
        if (field.type === 'email' && field.value && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(field.value)) {
          valid = false; field.classList.add('is-invalid');
          if (err) err.textContent = 'Enter a valid email address.';
        }
      });
      if (!valid) e.preventDefault();
    });
    form.querySelectorAll('[required]').forEach(f => {
      f.addEventListener('input', () => f.classList.remove('is-invalid'));
    });
  });
}

// ─── Hover Effects (landing cards) ───────────────────────────────────────────
function initHoverEffects() {
  document.querySelectorAll('.feature-card, .service-card, .stat-card').forEach(card => {
    card.addEventListener('mouseenter', () => card.classList.add('hovered'));
    card.addEventListener('mouseleave', () => card.classList.remove('hovered'));
  });
}

// ─── Toast Notifications ─────────────────────────────────────────────────────
function showToast(msg, type = 'info') {
  let container = document.querySelector('.toast-container');
  if (!container) {
    container = document.createElement('div');
    container.className = 'toast-container';
    Object.assign(container.style, { position:'fixed', bottom:'24px', right:'24px', zIndex:'9999', display:'flex', flexDirection:'column', gap:'8px' });
    document.body.appendChild(container);
  }
  const toast = document.createElement('div');
  toast.textContent = msg;
  const colors = { success:'#2F7D32', danger:'#B91C1C', warning:'#B45309', info:'#1E40AF' };
  Object.assign(toast.style, { background: colors[type] || colors.info, color:'#fff', padding:'12px 20px', borderRadius:'10px', fontSize:'.9rem', fontWeight:'500', opacity:'0', transform:'translateY(8px)', transition:'all .3s' });
  container.appendChild(toast);
  setTimeout(() => { toast.style.opacity = '1'; toast.style.transform = 'translateY(0)'; }, 10);
  setTimeout(() => { toast.style.opacity = '0'; setTimeout(() => toast.remove(), 300); }, 3500);
}

// ─── Accessibility: focus-visible keyboard nav ────────────────────────────────
function initAccessibility() {
  document.addEventListener('keydown', e => { if (e.key === 'Tab') document.body.classList.add('keyboard-nav'); });
  document.addEventListener('mousedown', () => document.body.classList.remove('keyboard-nav'));
}

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', () => {
  initNavigation();
  initScrollReveal();
  initCounterAnimations();
  initTypingEffect();
  initScrollProgress();
  initFormValidation();
  initHoverEffects();
  initAccessibility();
});
