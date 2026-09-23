(function(){
'use strict';
const config={url:'https://vwzdzmfewqkzaokdwzyj.supabase.co',anonKey:'sb_publishable_Sw0O5MWTbjr11gnhnDZQPQ_DHnzUD0u'};
let clientPromise;
async function getClient(){
 if(clientPromise)return clientPromise;
 clientPromise=new Promise((resolve,reject)=>{
  if(window.supabase?.createClient){resolve(window.supabase);return;}
  const s=document.createElement('script');s.src='https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/dist/umd/supabase.min.js';s.onload=()=>resolve(window.supabase);s.onerror=()=>reject(new Error('Não foi possível carregar o Supabase.'));document.head.appendChild(s);
 }).then(lib=>lib.createClient(config.url,config.anonKey));
 return clientPromise;
}
window.PromotorSupabase={
 async signIn(email,password){const c=await getClient();const r=await c.auth.signInWithPassword({email,password});if(r.error)throw r.error;return r.data;},
 async resetPassword(email){const c=await getClient();const r=await c.auth.resetPasswordForEmail(email,{redirectTo:location.href});if(r.error)throw r.error;return r.data;},
 async session(){const c=await getClient();const r=await c.auth.getSession();if(r.error)throw r.error;return r.data.session;},
 async signOut(){const c=await getClient();const r=await c.auth.signOut();if(r.error)throw r.error;},
 async listProducts(){const c=await getClient();const r=await c.from('promotor_products').select('*').order('created_at',{ascending:false});if(r.error)throw r.error;return r.data||[];},
 async addProduct(payload){const c=await getClient();const r=await c.from('promotor_products').insert(payload).select().single();if(r.error)throw r.error;return r.data;}
};
})();
