import { Router, Request, Response } from 'express';
import { AiService } from './ai.service';

export const aiRouter = Router();

// POST /api/v1/ai/dining-recommendations
aiRouter.post('/dining-recommendations', async (req: Request, res: Response) => {
  const { destination = 'Maceió', state = 'Alagoas', dayNumber = 1, activities = [] } = req.body;

  try {
    const recommendations = await AiService.getDiningRecommendations({
      destination,
      state,
      dayNumber: Number(dayNumber),
      activities
    });

    return res.json({
      success: true,
      data: recommendations
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao gerar recomendações de restaurantes com IA',
      error: (error as Error).message
    });
  }
});
