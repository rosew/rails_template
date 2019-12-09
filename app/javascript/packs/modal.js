window.hideModal = function(modal_id) {
  const el = document.getElementById(modal_id);
  el.classList.add('dn');
  el.classList.remove('db');
}

window.showModal = function(modal_id) {
  const el = document.getElementById(modal_id);
  el.classList.add('db');
  el.classList.remove('dn');
}
