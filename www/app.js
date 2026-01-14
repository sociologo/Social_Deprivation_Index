// ==========================================
// SocioSpatial Analytics – Micro UX Engine
// ==========================================

/*
Uso micro-JavaScript para escuchar eventos enviados desde 
el server Shiny cuando cambian KPIs, de modo que el frontend 
reaccione solo donde es necesario. Esto mejora la claridad del dashboard, 
reduce renders innecesarios y crea feedback visual inmediato para el usuario.
*/



Shiny.addCustomMessageHandler("kpiUpdate", function(payload) {
  
  const ids = payload.ids || [];
  const mobile = window.innerWidth < 768;

  ids.forEach((id, i) => {
    const el = document.getElementById(id);
    if (!el) return;

    // reset
    el.classList.remove("kpi-flash");

    // staggered highlight
    setTimeout(() => {
      el.classList.add("kpi-flash");
      setTimeout(() => el.classList.remove("kpi-flash"), 600);
    }, i * 120);
  });

  // UX assist: scroll only on mobile
  if (mobile && ids.length > 0) {
    const first = document.getElementById(ids[0]);
    if (first) {
      first.scrollIntoView({ behavior: "smooth", block: "center" });
    }
  }
});
