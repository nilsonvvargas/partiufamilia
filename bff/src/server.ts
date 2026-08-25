import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { tripsRouter } from './modules/trips/trips.router';
import { authRouter } from './modules/auth/auth.router';
import { itineraryRouter } from './modules/itinerary/itinerary.router';
import { expensesRouter } from './modules/expenses/expenses.router';
import { diningRouter } from './modules/dining/dining.router';
import { stayRouter } from './modules/stay/stay.router';
import { packingRouter } from './modules/packing/packing.router';
import { contactsRouter } from './modules/contacts/contacts.router';
import { dashboardRouter } from './modules/dashboard/dashboard.router';

dotenv.config();

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

// Request logger for BFF observability
app.use((req, res, next) => {
  console.log(`[BFF ${new Date().toLocaleTimeString()}] ${req.method} ${req.url}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString(), service: 'Família Partiu BFF' });
});

// Register Module Routes
app.use('/api/v1/auth', authRouter);
app.use('/api/v1/trips', tripsRouter);
app.use('/api/v1/dashboard', dashboardRouter);
app.use('/api/v1/itinerary', itineraryRouter);
app.use('/api/v1/expenses', expensesRouter);
app.use('/api/v1/dining', diningRouter);
app.use('/api/v1/stay', stayRouter);
app.use('/api/v1/packing', packingRouter);
app.use('/api/v1/contacts', contactsRouter);

app.listen(port, () => {
  console.log(`🚀 Família Partiu BFF rodando com sucesso na porta ${port}`);
  console.log(`📡 Endpoints disponíveis: http://localhost:${port}/api/v1/trips`);
});
