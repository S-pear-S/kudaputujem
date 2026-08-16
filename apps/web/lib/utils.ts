import { format, parseISO } from 'date-fns';
import { sr } from 'date-fns/locale';
import type { BoardType, TransportType } from './types';

export function formatDate(iso: string): string {
  return format(parseISO(iso), 'd. MMM yyyy.', { locale: sr });
}

export function formatDateShort(iso: string): string {
  return format(parseISO(iso), 'd.M.', { locale: sr });
}

export function formatPrice(amount: number, currency: string): string {
  return new Intl.NumberFormat('sr-RS', {
    style: 'currency',
    currency,
    maximumFractionDigits: 0,
  }).format(amount);
}

export function formatPriceRsd(rsd: number): string {
  return new Intl.NumberFormat('sr-RS', {
    style: 'currency',
    currency: 'RSD',
    maximumFractionDigits: 0,
  }).format(rsd);
}

export const BOARD_LABEL: Record<BoardType, string> = {
  RO: 'Bez ishrane',
  BB: 'Noćenje s doručkom',
  HB: 'Polupansion',
  FB: 'Pun pansion',
  AI: 'All inclusive',
  UAI: 'Ultra all inclusive',
  NONE: '',
};

export const TRANSPORT_LABEL: Record<TransportType, string> = {
  BUS: 'Autobus',
  PLANE: 'Avion',
  TRAIN: 'Voz',
  FERRY: 'Brod',
  MINIVAN: 'Kombi',
  OWN: 'Sopstveni prevoz',
  NONE: '',
};

export const TRANSPORT_ICON: Record<TransportType, string> = {
  BUS: '🚌',
  PLANE: '✈️',
  TRAIN: '🚂',
  FERRY: '⛴️',
  MINIVAN: '🚐',
  OWN: '🚗',
  NONE: '',
};

export function starsLabel(stars: number | null): string {
  if (!stars) return '';
  return '★'.repeat(Math.floor(stars));
}

export function relativeTime(iso: string): string {
  const diff = Date.now() - new Date(iso).getTime();
  const hours = Math.floor(diff / 3_600_000);
  if (hours < 1) return 'pre manje od sata';
  if (hours < 24) return `pre ${hours}h`;
  const days = Math.floor(hours / 24);
  return `pre ${days} dan${days === 1 ? '' : 'a'}`;
}
