import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  // Adicione esta seção de configuração do TypeScript
  typescript: {
    // AVISO!!
    // Permite que o build de produção seja concluído com sucesso
    // mesmo que o projeto tenha erros de tipo.
    ignoreBuildErrors: true,
  },
  devIndicators: false
}

export default nextConfig
