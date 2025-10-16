# agent-ui/Dockerfile

# --- Estágio 1: Builder ---
# Usamos uma imagem Node.js completa para instalar dependências e construir o projeto.
FROM node:20-alpine AS builder

# Define o gerenciador de pacotes para o pnpm
RUN npm install -g pnpm

WORKDIR /app

# Copia os arquivos de definição de dependências primeiro para aproveitar o cache do Docker
COPY package.json ./
RUN pnpm install

# Copia o resto do código da aplicação
COPY . .

# Constrói a aplicação para produção.
# NEXT_PUBLIC_API_URL será passado pelo docker-compose.yml
ARG NEXT_PUBLIC_API_URL
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
RUN pnpm build

# --- Estágio 2: Runner ---
# Usamos uma imagem Node.js menor para a execução, pois não precisamos mais das dependências de build.
FROM node:20-alpine AS runner

WORKDIR /app

# Define o ambiente para produção
ENV NODE_ENV=production

# Cria um usuário não-root para segurança
RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

# Copia os artefatos construídos do estágio 'builder'
# COPY --from=builder /app/public ./public
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./package.json

# Define o usuário para executar a aplicação
USER nextjs

# Expõe a porta 3000, que é a porta padrão do Next.js
EXPOSE 3000

# O comando para iniciar o servidor de produção do Next.js
CMD ["pnpm", "start"]