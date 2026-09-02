# Etapa única, imagen liviana
FROM node:20-alpine

WORKDIR /app

# Copiamos solo los manifiestos primero para aprovechar la cache de capas
COPY package*.json ./

RUN npm ci --omit=dev

# Copiamos el resto del código
COPY . .

# Ajusta este puerto al que use tu server.js (process.env.PORT || 3000)
EXPOSE 3000

CMD ["node", "server.js"]