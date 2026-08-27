export interface DiningRecommendation {
  name: string;
  cuisine: string;
  specialty: string;
  address: string;
  neighborhood: string;
  suggestedMeal: 'Almoço' | 'Jantar' | 'Petisco & Praia' | 'Café & Sobremesa';
  suggestedTime: string;
  rating: number;
  priceLevel: '$' | '$$' | '$$$' | '$$$$';
  reason: string;
  icon: string;
}

// In-memory cache with 24h TTL
const aiRecommendationsCache = new Map<string, { timestamp: number; data: DiningRecommendation[] }>();
const CACHE_TTL_MS = 24 * 60 * 60 * 1000;

export class AiService {
  private static getApiKey(): string {
    return process.env.GEMINI_API_KEY || '';
  }

  /**
   * Generates AI dining recommendations based on destination and the day's itinerary locations.
   */
  static async getDiningRecommendations(params: {
    destination: string;
    state?: string;
    dayNumber: number;
    activities: Array<{ title: string; location?: string; tag?: string }>;
  }): Promise<DiningRecommendation[]> {
    const { destination, state = '', dayNumber, activities = [] } = params;

    const locationsStr = activities
      .map(a => `${a.title}${a.location ? ` (${a.location})` : ''}`)
      .join(', ');

    const cacheKey = `${destination.toLowerCase()}_day${dayNumber}_${locationsStr.toLowerCase()}`;
    const cached = aiRecommendationsCache.get(cacheKey);
    if (cached && Date.now() - cached.timestamp < CACHE_TTL_MS) {
      return cached.data;
    }

    const apiKey = this.getApiKey();

    if (!apiKey) {
      return this.getFallbackRecommendations(destination, dayNumber, activities);
    }

    const prompt = `Você é um guia turístico e gastronômico de elite no Brasil.
O usuário está na viagem em "${destination} - ${state}", no Dia ${dayNumber}.
As atividades e pontos turísticos planejados para este dia são:
${locationsStr || 'Passeios pelas principais atrações e praias da região'}

Sua missão:
Recomende exatamente 4 restaurantes, quiosques de praia ou bistrôs reais, famosos e bem avaliados que fiquem PRÓXIMOS ou no caminho dessas atividades deste dia (ou no mesmo bairro), para que o usuário não precise se deslocar muito.

Retorne EXCLUSIVAMENTE um array JSON válido (sem tags markdown extras ou crases fora do json) com a seguinte estrutura:
[
  {
    "name": "Nome Real do Restaurante",
    "cuisine": "Tipo de Culinária (ex: Frutos do Mar, Regional Alagoana, Pizzaria, etc.)",
    "specialty": "Prato Destaque imperdível (ex: Chiclete de Camarão, Peixada ao Coco)",
    "address": "Endereço aproximado ou praia/bairro",
    "neighborhood": "Bairro / Praia",
    "suggestedMeal": "Almoço" | "Jantar" | "Petisco & Praia" | "Café & Sobremesa",
    "suggestedTime": "12:30" ou "20:00",
    "rating": 4.8,
    "priceLevel": "$$" ou "$$$",
    "reason": "Frase curta explicando por que é a melhor opção perto do passeio de hoje",
    "icon": "🦞" ou "🍕" ou "🥩" ou "🏖️"
  }
]`;

    try {
      const response = await fetch(
        `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${apiKey}`,
        {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            contents: [
              {
                parts: [{ text: prompt }]
              }
            ],
            generationConfig: {
              temperature: 0.4,
              responseMimeType: 'application/json'
            }
          })
        }
      );

      if (!response.ok) {
        console.warn(`Gemini API returned status ${response.status}, trying fallback model gemini-1.5-flash...`);
        const fbRes = await fetch(
          `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${apiKey}`,
          {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
              generationConfig: { responseMimeType: 'application/json' }
            })
          }
        );

        if (!fbRes.ok) {
          return this.getFallbackRecommendations(destination, dayNumber, activities);
        }

        const fbData: any = await fbRes.json();
        const text = fbData.candidates?.[0]?.content?.parts?.[0]?.text;
        if (text) {
          const parsed = JSON.parse(text);
          if (Array.isArray(parsed) && parsed.length > 0) {
            aiRecommendationsCache.set(cacheKey, { timestamp: Date.now(), data: parsed });
            return parsed;
          }
        }
        return this.getFallbackRecommendations(destination, dayNumber, activities);
      }

      const data: any = await response.json();
      const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
      if (text) {
        const parsed = JSON.parse(text);
        if (Array.isArray(parsed) && parsed.length > 0) {
          aiRecommendationsCache.set(cacheKey, { timestamp: Date.now(), data: parsed });
          return parsed;
        }
      }

      return this.getFallbackRecommendations(destination, dayNumber, activities);
    } catch (error) {
      console.warn('AI recommendation fetch error:', (error as Error).message);
      return this.getFallbackRecommendations(destination, dayNumber, activities);
    }
  }

  /**
   * Fallback curated recommendations if offline or rate-limited
   */
  private static getFallbackRecommendations(
    destination: string,
    dayNumber: number,
    activities: Array<{ title: string; location?: string }>
  ): DiningRecommendation[] {
    const isMaceio = destination.toLowerCase().includes('macei');
    const actText = activities.map(a => `${a.title} ${a.location || ''}`).join(' ').toLowerCase();

    if (isMaceio) {
      if (actText.includes('gunga') || actText.includes('francês') || actText.includes('frances') || actText.includes('sul')) {
        return [
          {
            name: 'Restaurante e Bar do Pato',
            cuisine: 'Frutos do Mar e Massas',
            specialty: 'Lagosta Grelhada na Manteiga e Camarão no Coco',
            address: 'Rua do Pato, Barra de São Miguel',
            neighborhood: 'Barra de São Miguel',
            suggestedMeal: 'Almoço',
            suggestedTime: '13:00',
            rating: 4.8,
            priceLevel: '$$$',
            reason: 'Parada perfeita no retorno do Gunga e Barra de São Miguel com vista da lagoa.',
            icon: '🦞'
          },
          {
            name: 'Kioske da Ana (Praia do Gunga)',
            cuisine: 'Petiscos e Peixes de Praia',
            specialty: 'Peixe Frito Inteiro com Macaxeira e Vinagrete',
            address: 'Praia do Gunga, Roteiro',
            neighborhood: 'Praia do Gunga',
            suggestedMeal: 'Petisco & Praia',
            suggestedTime: '11:30',
            rating: 4.6,
            priceLevel: '$$',
            reason: 'Estrutura com sombra e pé na areia enquanto curte as falésias.',
            icon: '🏖️'
          },
          {
            name: 'Pizzaria Massarella',
            cuisine: 'Italiana & Pizzaria',
            specialty: 'Pizza Forno a Lenha de Camarão e Catupiry',
            address: 'R. José Freire Moura, 255 - Ponta Verde',
            neighborhood: 'Ponta Verde',
            suggestedMeal: 'Jantar',
            suggestedTime: '20:00',
            rating: 4.7,
            priceLevel: '$$',
            reason: 'Ambiente aconchegante para descansar após um longo dia na praia sul.',
            icon: '🍕'
          },
          {
            name: 'Sorveteria Bali',
            cuisine: 'Sobremesas & Sorvetes Artesanais',
            specialty: 'Sorvete de Tapioca com Doce de Leite e Caipirinha',
            address: 'Av. Silvio Carlos Viana - Ponta Verde',
            neighborhood: 'Ponta Verde',
            suggestedMeal: 'Café & Sobremesa',
            suggestedTime: '21:30',
            rating: 4.9,
            priceLevel: '$',
            reason: 'Caminhada noturna na orla com o melhor sorvete de frutas regionais.',
            icon: '🍦'
          }
        ];
      }

      if (actText.includes('maragogi') || actText.includes('milagres') || actText.includes('norte')) {
        return [
          {
            name: 'Restaurante Maragaço',
            cuisine: 'Frutos do Mar e Regional',
            specialty: 'Chiclete de Camarão com Queijo Coalho Dourado',
            address: 'Av. Senador Rui Palmeira, Maragogi',
            neighborhood: 'Maragogi',
            suggestedMeal: 'Almoço',
            suggestedTime: '12:30',
            rating: 4.8,
            priceLevel: '$$$',
            reason: 'De frente para o mar de Maragogi após as piscinas naturais.',
            icon: '🍤'
          },
          {
            name: 'Restaurante No Quintal',
            cuisine: 'Contemporânea e Orgânica',
            specialty: 'Peixe fresco em crosta de castanha de caju',
            address: 'Rua da Praia, São Miguel dos Milagres',
            neighborhood: 'São Miguel dos Milagres',
            suggestedMeal: 'Almoço',
            suggestedTime: '13:30',
            rating: 4.9,
            priceLevel: '$$$',
            reason: 'Ambiente rústico e sustentável com culinária impecável em Milagres.',
            icon: '🌿'
          },
          {
            name: 'Divina Gula',
            cuisine: 'Brasileira e Mineira com Toque Alagoano',
            specialty: 'Picanha na Pedra e Costelinha com Goiabada Picante',
            address: 'Av. Eng. Paulo Brandão Nogueira, 85 - Jatiúca',
            neighborhood: 'Jatiúca',
            suggestedMeal: 'Jantar',
            suggestedTime: '20:30',
            rating: 4.9,
            priceLevel: '$$$',
            reason: 'Um dos restaurantes mais premiados de Alagoas, perfeito para fechar o dia.',
            icon: '🥩'
          },
          {
            name: 'Bodega do Sertão',
            cuisine: 'Nordestina Tradicional',
            specialty: 'Buffet Típico com Baião de Dois e Carne de Sol na Nata',
            address: 'Av. Júlio Marques Luz, 62 - Jatiúca',
            neighborhood: 'Jatiúca',
            suggestedMeal: 'Jantar',
            suggestedTime: '19:30',
            rating: 4.8,
            priceLevel: '$$',
            reason: 'Decoração temática com bule gigante e a melhor comida sertaneja.',
            icon: '🌵'
          }
        ];
      }

      // Default Maceió Urban / Day recommendations
      return [
        {
          name: 'Restaurante Janga',
          cuisine: 'Frutos do Mar Contemporâneo',
          specialty: 'Camarão Jangadeiro com Risoto de Alho-poró',
          address: 'R. Eng. Mário de Gusmão, 868 - Ponta Verde',
          neighborhood: 'Ponta Verde',
          suggestedMeal: 'Jantar',
          suggestedTime: '20:00',
          rating: 4.9,
          priceLevel: '$$$',
          reason: 'Ambiente sofisticado e pratos fartos para toda a família.',
          icon: '🦞'
        },
        {
          name: 'Imperador dos Camarões',
          cuisine: 'Frutos do Mar Tradicional',
          specialty: 'O Famoso Chiclete de Camarão Original',
          address: 'Av. Dr. Antônio Gouveia, 21 - Pajuçara',
          neighborhood: 'Pajuçara',
          suggestedMeal: 'Almoço',
          suggestedTime: '12:30',
          rating: 4.7,
          priceLevel: '$$',
          reason: 'Na orla de Pajuçara, ao lado do ponto de embarque das jangadas.',
          icon: '🍤'
        },
        {
          name: 'Restaurante Akuaba',
          cuisine: 'Afro-brasileira & Frutos do Mar',
          specialty: 'Moqueca de Camarão com Acarajé de Entrada',
          address: 'R. Ferroviário Manoel Gonçalves Filho, 6 - Mangabeiras',
          neighborhood: 'Mangabeiras',
          suggestedMeal: 'Jantar',
          suggestedTime: '20:30',
          rating: 4.8,
          priceLevel: '$$$',
          reason: 'Vencedor de prêmios gastronômicos nacionais com sabores marcantes.',
          icon: '🍲'
        },
        {
          name: 'Lopana Beach Club',
          cuisine: 'Petiscos Gourmet & Drinks',
          specialty: 'Pastel de Camarão com Catupiry e Caipiroscas Tropicais',
          address: 'Av. Silvio Carlos Viana, 27 - Ponta Verde',
          neighborhood: 'Ponta Verde',
          suggestedMeal: 'Petisco & Praia',
          suggestedTime: '16:30',
          rating: 4.8,
          priceLevel: '$$$',
          reason: 'Pôr do sol à beira-mar com música ao vivo e barcos privativos.',
          icon: '🏖️'
        }
      ];
    }

    // Generic fallback for any other destination
    return [
      {
        name: `Restaurante Central de ${destination}`,
        cuisine: 'Regional e Contemporânea',
        specialty: 'Prato Típico da Casa com Ingredientes Locais',
        address: `Centro / Orla de ${destination}`,
        neighborhood: 'Centro',
        suggestedMeal: 'Almoço',
        suggestedTime: '12:30',
        rating: 4.8,
        priceLevel: '$$',
        reason: 'Excelente localização próximo aos pontos de interesse do dia.',
        icon: '🍽️'
      },
      {
        name: `Bistrô & Parrilla ${destination}`,
        cuisine: 'Carnes Nobres & Massas',
        specialty: 'Cortes Especiais e Massas Artesanais',
        address: `Av. Principal, ${destination}`,
        neighborhood: 'Bairro Nobre',
        suggestedMeal: 'Jantar',
        suggestedTime: '20:00',
        rating: 4.9,
        priceLevel: '$$$',
        reason: 'Opção perfeita para um jantar memorável em família.',
        icon: '🥩'
      }
    ];
  }
}
