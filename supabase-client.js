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
 async signUp({email,password,full_name,company}){const c=await getClient();const redirectTo=location.origin+location.pathname;const r=await c.auth.signUp({email,password,options:{emailRedirectTo:redirectTo,data:{full_name,company}}});if(r.error)throw r.error;return r.data;},
 async getProfile(userId){const c=await getClient();const r=await c.from('promotor_profiles').select('*').eq('user_id',userId).maybeSingle();if(r.error)throw r.error;return r.data||null;},
 async lookupBarcode(ean){const c=await getClient();const cloud=await c.from('promotor_products').select('name,ean,company').eq('ean',ean).limit(1).maybeSingle();if(cloud.data)return cloud.data;const response=await fetch('https://world.openfoodfacts.org/api/v2/product/'+encodeURIComponent(ean)+'.json');if(!response.ok)return null;const data=await response.json();if(data.status!==1)return null;const p=data.product||{};return {name:p.product_name_pt||p.product_name||p.generic_name||'',company:p.brands||null,ean};},
 async uploadProductPhoto(file,userId){const c=await getClient();const ext=(file.name.split('.').pop()||'jpg').toLowerCase();const path=userId+'/'+Date.now()+'-'+Math.random().toString(36).slice(2)+'.'+ext;const r=await c.storage.from('promotor-product-photos').upload(path,file,{upsert:false,contentType:file.type||'image/jpeg'});if(r.error)throw r.error;const pub=c.storage.from('promotor-product-photos').getPublicUrl(path);return pub.data.publicUrl;},
 async resetPassword(email){const c=await getClient();const r=await c.auth.resetPasswordForEmail(email,{redirectTo:location.href});if(r.error)throw r.error;return r.data;},
 async session(){const c=await getClient();const r=await c.auth.getSession();if(r.error)throw r.error;return r.data.session;},
 async signOut(){const c=await getClient();const r=await c.auth.signOut();if(r.error)throw r.error;},
 async listProducts(){const c=await getClient();const r=await c.from('promotor_products').select('*').order('created_at',{ascending:false});if(r.error)throw r.error;return r.data||[];},
 async addProduct(payload){const c=await getClient();const r=await c.from('promotor_products').insert(payload).select().single();if(r.error)throw r.error;return r.data;},
 async deleteProducts(ids){const c=await getClient();const r=await c.from('promotor_products').delete().in('id',ids).eq('user_id',(await c.auth.getUser()).data.user.id);if(r.error)throw r.error;return r.data;},
 async subscribeProducts(onChange){const c=await getClient();const channel=c.channel('promotor-pa-products').on('postgres_changes',{event:'*',schema:'public',table:'promotor_products'},payload=>{try{onChange?.(payload);}catch(e){console.warn(e);}});channel.subscribe();return channel;}
};
})();
