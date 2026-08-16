import { Clock, Star } from 'lucide-react';
import Image from 'next/image';
import type { OfferCard as OfferCardType } from '@/lib/types';
import {
  BOARD_LABEL,
  TRANSPORT_ICON,
  formatDate,
  formatPrice,
  relativeTime,
} from '@/lib/utils';
import LeadModal from './LeadModal';

interface Props {
  offer: OfferCardType;
}

export default function OfferCard({ offer }: Props) {
  const { accommodation, destination, departure, price, agency, images } = offer;
  const image = images[0];

  return (
    <article className="flex flex-col sm:flex-row bg-white rounded-xl border border-slate-200 overflow-hidden hover:shadow-md transition-shadow">
      {/* Slika */}
      <div className="relative w-full sm:w-52 h-44 sm:h-auto shrink-0 bg-slate-100">
        {image ? (
          <Image
            src={image}
            alt={accommodation?.name ?? offer.title}
            fill
            className="object-cover"
            sizes="(max-width: 640px) 100vw, 208px"
          />
        ) : (
          <div className="absolute inset-0 flex items-center justify-center text-slate-300 text-4xl">
            🏖️
          </div>
        )}
        {offer.isLastMinute && (
          <span className="absolute top-2 left-2 bg-red-500 text-white text-xs font-bold px-2 py-0.5 rounded">
            Last minute
          </span>
        )}
      </div>

      {/* Sadrzaj */}
      <div className="flex flex-col flex-1 p-4 gap-2">
        {/* Naslov i destinacija */}
        <div>
          <div className="flex items-start justify-between gap-2">
            <div>
              {destination && (
                <p className="text-xs text-blue-600 font-medium mb-0.5">{destination.nameSr}</p>
              )}
              <h2 className="font-semibold text-slate-900 leading-snug">
                {accommodation?.name ?? offer.title}
              </h2>
            </div>
            {accommodation?.stars != null && (
              <div className="flex items-center gap-0.5 text-amber-400 shrink-0 mt-0.5">
                <Star size={13} fill="currentColor" />
                <span className="text-xs font-medium text-slate-600">
                  {accommodation.stars.toFixed(0)}
                </span>
              </div>
            )}
          </div>
        </div>

        {/* Detalji termina */}
        <div className="flex flex-wrap gap-x-3 gap-y-1 text-sm text-slate-600">
          <span>
            {formatDate(departure.startDate)} – {formatDate(departure.endDate)}
          </span>
          <span className="text-slate-400">·</span>
          <span>{departure.nights} noćenja</span>
          {departure.departurePlaceRaw && (
            <>
              <span className="text-slate-400">·</span>
              <span>
                {TRANSPORT_ICON[departure.transportType]} {departure.departurePlaceRaw}
              </span>
            </>
          )}
          {departure.boardType !== 'NONE' && (
            <>
              <span className="text-slate-400">·</span>
              <span>{BOARD_LABEL[departure.boardType]}</span>
            </>
          )}
        </div>

        {/* Footer: agencija, cena, dugme */}
        <div className="flex items-end justify-between mt-auto pt-2 border-t border-slate-100">
          <div className="flex items-center gap-1.5 min-w-0">
            {agency.logoUrl ? (
              <Image
                src={agency.logoUrl}
                alt={agency.name}
                width={20}
                height={20}
                className="rounded object-contain"
              />
            ) : null}
            <span className="text-xs text-slate-400 truncate">{agency.name}</span>
            <span className="text-xs text-slate-300 ml-1 flex items-center gap-0.5">
              <Clock size={10} />
              {relativeTime(offer.lastSeenAt)}
            </span>
          </div>

          <div className="flex items-center gap-3 shrink-0">
            <div className="text-right">
              <p className="text-xl font-bold text-slate-900">
                {formatPrice(price.perPersonAmount, price.currency)}
              </p>
              <p className="text-xs text-slate-400">po osobi{!price.isExact && '*'}</p>
            </div>
            <LeadModal offer={offer} />
          </div>
        </div>
      </div>
    </article>
  );
}
