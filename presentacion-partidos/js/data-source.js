/* Lectura del contenido editable desde Supabase (REST), con caché local y respaldo al contenido incluido. */
(function () {
  'use strict';
  const C = window.MDPP_CONFIG || {};
  const slugOf = t => String(t || '').normalize('NFD').replace(/[̀-ͯ]/g, '').toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '').slice(0, 80);
  const store = {
    get(k) { try { return localStorage.getItem(k); } catch (e) { return null; } },
    set(k, v) { try { localStorage.setItem(k, v); } catch (e) { /* sin almacenamiento */ } }
  };
  async function fetchItems(deckSlug) {
    const force = /[?&]local=1/.test(location.search);
    if (force || C.enabled === false || !C.url || !C.anonKey) return null;
    const cacheKey = 'mdpp-cache-' + deckSlug;
    const q = '/rest/v1/mdpp_items?select=slug,title,minutes,css_class,nochrome,html,notes,locked,published,meta,mdpp_decks!inner(slug)&mdpp_decks.slug=eq.' + encodeURIComponent(deckSlug);
    const ctrl = new AbortController(), to = setTimeout(() => ctrl.abort(), 4000);
    try {
      const res = await fetch(C.url.replace(/\/$/, '') + q, { headers: { apikey: C.anonKey, Authorization: 'Bearer ' + C.anonKey }, signal: ctrl.signal });
      if (!res.ok) throw new Error('HTTP ' + res.status);
      const rows = await res.json();
      store.set(cacheKey, JSON.stringify(rows));
      return rows;
    } catch (e) {
      console.warn('[MDPP] Sin conexión con Supabase; se usa la última copia o el contenido local.', e.message);
      try { return JSON.parse(store.get(cacheKey) || 'null'); } catch (er) { return null; }
    } finally { clearTimeout(to); }
  }
  window.MDPP = { slugOf, fetchItems };
})();
