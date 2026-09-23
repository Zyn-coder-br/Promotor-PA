# Projeto Promotor PA — V01

Primeira base independente do Promotor PA, inspirada no layout do Vencimento PA.

## Incluído
- Login real via Supabase Auth.
- Recuperação de senha por e-mail.
- Página Início.
- Página Produtos.
- Cadastro de produtos na tabela `promotor_products`.
- RLS para que cada usuário veja apenas seus próprios produtos.
- Layout responsivo com tema escuro e navegação semelhante ao Vencimento PA.

## Configuração
1. Execute `SUPABASE_PROMOTOR_PA_V01.sql` no SQL Editor do Supabase.
2. Publique os arquivos em um projeto separado do GitHub Pages.
3. Configure no Supabase Auth a URL do GitHub Pages para redirecionamentos, se necessário.


## V03 - Perfil, empresa, foto e consulta de EAN
- Cadastro de usuário com nome e empresa.
- Empresa vinculada automaticamente aos produtos.
- Upload de foto para o Storage do Supabase.
- Busca de EAN no catálogo da nuvem e no Open Food Facts.
- Execute a migração SQL atualizada antes de publicar.
