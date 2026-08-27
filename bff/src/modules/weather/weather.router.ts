import { Router, Request, Response } from 'express';
import { WeatherService } from './weather.service';

export const weatherRouter = Router();

// GET /api/v1/weather?city=Maceio&state=Alagoas
weatherRouter.get('/', async (req: Request, res: Response) => {
  const city = (req.query.city as string) || 'Maceió';
  const state = req.query.state as string | undefined;

  try {
    const weatherData = await WeatherService.getWeatherForDestination(city, state);
    return res.json({
      success: true,
      data: weatherData
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: 'Erro ao consultar previsão do tempo',
      error: (error as Error).message
    });
  }
});
