/* Conexión opcional a Supabase. Sin URL y clave, todo funciona con el contenido local.
   La clave "anon" es pública por diseño: la protegen las políticas RLS de la migración.
   NUNCA ponga aquí la clave "service_role". */
window.MDPP_CONFIG = {
  enabled: true,                  // cambie a true cuando la base esté lista
  url: 'https://tayabtshfgbbzsbckknd.supabase.co',                        // ej. https://xxxx.supabase.co
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRheWFidHNoZmdiYnpzYmNra25kIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTEzMjMzMzAsImV4cCI6MjEwNjg5OTMzMH0.UzJIl418RahLslK3lrdJrnU_OEjmP7lF9olR_MSA4eE',                    // clave anon / publishable del proyecto
  deck: 'presentacion-partidos'   // slug del deck en mdpp_decks
};
