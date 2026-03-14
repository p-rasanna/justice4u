// main.js — Justice4U interactions

document.addEventListener('DOMContentLoaded', () => {
  j4uInitModal();
  j4uInitScrollReveal();
  j4uInitCounters();
  j4uInitMagneticButtons();
  j4uInitNavToggle();
});

/* ============= MODAL ============= */

function j4uInitModal() {
  const modalBackdrop = document.querySelector('[data-j4u-modal]');
  const openButtons = document.querySelectorAll('[data-j4u-open-modal]');
  const closeButton = document.querySelector('[data-j4u-close-modal]');
  let lastFocusedElement = null;

  if (!modalBackdrop) return;

  function openModal() {
    lastFocusedElement = document.activeElement;
    modalBackdrop.classList.add('is-open');
    modalBackdrop.setAttribute('aria-hidden', 'false');

    const firstButton = modalBackdrop.querySelector('.j4u-role-buttons button');
    if (firstButton) firstButton.focus();

    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    modalBackdrop.classList.remove('is-open');
    modalBackdrop.setAttribute('aria-hidden', 'true');
    document.body.style.overflow = '';

    if (lastFocusedElement && typeof lastFocusedElement.focus === 'function') {
      lastFocusedElement.focus();
    }
  }

  openButtons.forEach(btn => {
    btn.addEventListener('click', openModal);
  });

  if (closeButton) {
    closeButton.addEventListener('click', closeModal);
  }

  modalBackdrop.addEventListener('click', event => {
    if (event.target === modalBackdrop) {
      closeModal();
    }
  });

  document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && modalBackdrop.classList.contains('is-open')) {
      closeModal();
    }
  });
}

/* ============= SCROLL REVEAL ============= */

function j4uInitScrollReveal() {
  const revealEls = document.querySelectorAll('.j4u-reveal');

  if (revealEls.length === 0) return;

  // Fallback if IntersectionObserver is not supported
  if (!('IntersectionObserver' in window)) {
    revealEls.forEach(el => el.classList.add('j4u-reveal-visible'));
    return;
  }

  const observer = new IntersectionObserver(
    entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('j4u-reveal-visible');
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.18
    }
  );

  revealEls.forEach(el => observer.observe(el));
}

/* ============= HERO COUNTERS ============= */

function j4uInitCounters() {
  const counters = document.querySelectorAll('.hero-counter-value');
  if (counters.length === 0) return;

  const animate = el => {
    const target = parseInt(el.getAttribute('data-target'), 10);
    if (!target || Number.isNaN(target)) return;

    let current = 0;
    const duration = 1500;
    const start = performance.now();

    function step(now) {
      const progress = Math.min((now - start) / duration, 1);
      // Ease-out cubic
      const eased = 1 - Math.pow(1 - progress, 3);
      current = Math.floor(eased * target);
      el.textContent = current.toLocaleString();

      if (progress < 1) {
        requestAnimationFrame(step);
      }
    }

    requestAnimationFrame(step);
  };

  // If no IntersectionObserver, animate immediately
  if (!('IntersectionObserver' in window)) {
    counters.forEach(animate);
    return;
  }

  const observer = new IntersectionObserver(
    entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          animate(entry.target);
          observer.unobserve(entry.target);
        }
      });
    },
    {
      threshold: 0.4
    }
  );

  counters.forEach(counter => observer.observe(counter));
}

/* ============= MAGNETIC BUTTONS ============= */

function j4uInitMagneticButtons() {
  const magneticEls = document.querySelectorAll('.j4u-magnetic');
  if (magneticEls.length === 0) return;

  magneticEls.forEach(el => {
    const strength = 18;

    el.addEventListener('mousemove', event => {
      const rect = el.getBoundingClientRect();
      const relX = event.clientX - rect.left - rect.width / 2;
      const relY = event.clientY - rect.top - rect.height / 2;

      el.style.transform = `translate(${relX / strength}px, ${relY / strength}px)`;
    });

    el.addEventListener('mouseleave', () => {
      el.style.transform = 'translate(0, 0)';
    });
  });
}

/* ============= MOBILE NAV TOGGLE ============= */

function j4uInitNavToggle() {
  const toggle = document.querySelector('.nav-toggle');
  const menu = document.querySelector('.nav-menu');

  if (!toggle || !menu) return;

  toggle.addEventListener('click', () => {
    const isOpen = menu.style.display === 'flex';

    if (isOpen) {
      menu.style.display = 'none';
      toggle.setAttribute('aria-expanded', 'false');
    } else {
      menu.style.display = 'flex';
      menu.style.flexDirection = 'column';
      menu.style.gap = '0.75rem';
      toggle.setAttribute('aria-expanded', 'true');
    }
  });

  // Optional: close menu when clicking a link on mobile
  menu.addEventListener('click', event => {
    if (event.target.tagName === 'A' && window.innerWidth <= 768) {
      menu.style.display = 'none';
      toggle.setAttribute('aria-expanded', 'false');
    }
  });
}
