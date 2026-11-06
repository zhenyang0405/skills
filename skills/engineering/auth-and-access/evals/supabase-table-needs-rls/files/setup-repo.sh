#!/usr/bin/env bash
# Builds ./taskapp: a Vite + Supabase app. The existing todos table has no row-level security.
set -eu
rm -rf taskapp && mkdir -p taskapp/src/lib taskapp/supabase/migrations && cd taskapp
git init -q -b main
git config user.email dev@example.com && git config user.name dev
cat > package.json <<'EOF'
{
  "name": "taskapp",
  "version": "0.1.0",
  "type": "module",
  "scripts": { "dev": "vite", "build": "vite build" },
  "dependencies": { "@supabase/supabase-js": "^2.45.0" },
  "devDependencies": { "vite": "^5.4.0" }
}
EOF
cat > .env.example <<'EOF'
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key
# Used by scripts/seed.js only
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
EOF
cat > supabase/config.toml <<'EOF'
project_id = "taskapp"
EOF
cat > supabase/migrations/20261020120000_create_todos.sql <<'EOF'
create table public.todos (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade default auth.uid(),
  title text not null,
  done boolean not null default false,
  created_at timestamptz not null default now()
);
EOF
cat > src/lib/supabase.js <<'EOF'
import { createClient } from '@supabase/supabase-js';

export const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY,
);
EOF
cat > src/lib/todos.js <<'EOF'
import { supabase } from './supabase.js';

export async function listTodos() {
  const { data, error } = await supabase.from('todos').select('*').order('created_at');
  if (error) throw error;
  return data;
}

export async function addTodo(title) {
  const { data, error } = await supabase.from('todos').insert({ title }).select().single();
  if (error) throw error;
  return data;
}
EOF
cat > README.md <<'EOF'
# taskapp

A to-do app on Vite + Supabase. Users sign in with Supabase Auth (email magic link).
Database changes go in `supabase/migrations/` and are applied with `supabase db push`.
EOF
git add -A && git commit -qm "Todo app on Supabase"
