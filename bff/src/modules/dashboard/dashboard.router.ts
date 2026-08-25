import { Router, Request, Response } from 'express';
import {
  initialItineraries,
  initialExpenses,
  initialDining,
  initialStay,
  initialPacking,
  initialContacts
} from '../../data/seedData';

export const dashboardRouter = Router();

// GET aggregated home dashboard for Mobile Host App
dashboardRouter.get('/', async (req: Request, res: Response) => {
  // Aggregate snapshot for optimal single-roundtrip load
  const totalExpenses = initialExpenses.reduce((acc, curr) => acc + curr.amount, 0);
  const packedCount = initialPacking.filter(p => p.isPacked).length;
  const totalPacking = initialPacking.length;
  const nextTour = initialItineraries[0];
  const nextDinner = initialDining[0];

  return res.json({
    success: true,
    data: {
      destination: {
        city: 'Maceió',
        state: 'Alagoas',
        title: 'Paraíso das Águas 🏖️',
        tripDates: '10 Set - 15 Set 2026',
        weather: {
          temp: '29°C',
          condition: 'Ensolarado com brisa do mar',
          waterTemp: '27°C'
        }
      },
      staySnapshot: {
        name: initialStay.name,
        neighborhood: initialStay.neighborhood,
        wifiNetwork: initialStay.wifiNetwork,
        wifiPassword: initialStay.wifiPassword,
        checkIn: initialStay.checkIn
      },
      nextTour,
      nextDinner,
      stats: {
        totalDays: initialItineraries.length,
        totalExpenses,
        packingProgress: Math.round((packedCount / totalPacking) * 100),
        totalContacts: initialContacts.length
      }
    }
  });
});
