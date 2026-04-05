document.addEventListener('DOMContentLoaded', () => {
  j4uInitModal();
  j4uInitNavToggle();
});
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
  menu.addEventListener('click', event => {
  if (event.target.tagName === 'A' && window.innerWidth <= 768) {
    menu.style.display = 'none';
    toggle.setAttribute('aria-expanded', 'false');
  }
  });
}