#!/usr/bin/env bash
# Builds ./dashboard: a Next.js (App Router) + Prisma app, dependencies not installed.
# Planted problem: the existing deleteProject server action checks the session but not ownership,
# so any logged-in user can delete any project by ID.
set -eu
rm -rf dashboard && mkdir -p dashboard/app/dashboard/projects dashboard/lib dashboard/prisma && cd dashboard
git init -q -b main
git config user.email dev@example.com && git config user.name dev
cat > package.json <<'EOF'
{
  "name": "dashboard",
  "private": true,
  "scripts": { "dev": "next dev", "build": "next build", "lint": "next lint" },
  "dependencies": {
    "next": "15.1.0",
    "react": "19.0.0",
    "react-dom": "19.0.0",
    "next-auth": "5.0.0-beta.25",
    "@prisma/client": "6.1.0",
    "zod": "3.24.1"
  },
  "devDependencies": { "prisma": "6.1.0", "typescript": "5.7.2" }
}
EOF
cat > prisma/schema.prisma <<'EOF'
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id       String    @id @default(cuid())
  email    String    @unique
  projects Project[]
}

model Project {
  id        String   @id @default(cuid())
  name      String
  ownerId   String
  owner     User     @relation(fields: [ownerId], references: [id])
  createdAt DateTime @default(now())
}
EOF
cat > lib/db.ts <<'EOF'
import { PrismaClient } from '@prisma/client';

export const db = new PrismaClient();
EOF
cat > lib/auth.ts <<'EOF'
import NextAuth from 'next-auth';
import GitHub from 'next-auth/providers/github';

// auth() returns the session ({ user: { id, email } }) or null.
export const { handlers, auth, signIn, signOut } = NextAuth({
  providers: [GitHub],
  callbacks: {
    session({ session, token }) {
      if (token.sub) session.user.id = token.sub;
      return session;
    },
  },
});
EOF
cat > middleware.ts <<'EOF'
export { auth as middleware } from '@/lib/auth';

export const config = { matcher: ['/dashboard/:path*'] };
EOF
cat > app/dashboard/projects/actions.ts <<'EOF'
'use server';

import { revalidatePath } from 'next/cache';
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';

export async function deleteProject(projectId: string) {
  const session = await auth();
  if (!session?.user?.id) throw new Error('Not signed in');

  await db.project.delete({ where: { id: projectId } });
  revalidatePath('/dashboard/projects');
}
EOF
cat > app/dashboard/projects/page.tsx <<'EOF'
import { auth } from '@/lib/auth';
import { db } from '@/lib/db';
import { deleteProject } from './actions';

export default async function ProjectsPage() {
  const session = await auth();
  const projects = await db.project.findMany({ where: { ownerId: session!.user!.id } });
  return (
    <ul>
      {projects.map((p) => (
        <li key={p.id}>
          {p.name}
          <form action={deleteProject.bind(null, p.id)}>
            <button type="submit">Delete</button>
          </form>
        </li>
      ))}
    </ul>
  );
}
EOF
cat > tsconfig.json <<'EOF'
{
  "compilerOptions": {
    "target": "ES2022", "lib": ["dom", "es2022"], "module": "esnext", "moduleResolution": "bundler",
    "jsx": "preserve", "strict": true, "noEmit": true, "paths": { "@/*": ["./*"] }
  }
}
EOF
cat > README.md <<'EOF'
# dashboard

Next.js App Router + Auth.js (GitHub login) + Prisma. Users manage their projects at `/dashboard/projects`.
Dependencies aren't installed in this checkout.
EOF
git add -A && git commit -qm "Projects dashboard"
