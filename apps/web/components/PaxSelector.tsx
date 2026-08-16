'use client';

import { Minus, Plus, Users } from 'lucide-react';
import { useEffect, useRef, useState } from 'react';

interface PaxState {
  adults: number;
  childAges: number[];
}

interface PaxSelectorProps {
  value: PaxState;
  onChange: (v: PaxState) => void;
}

function Counter({
  label,
  value,
  min,
  max,
  onChange,
}: {
  label: string;
  value: number;
  min: number;
  max: number;
  onChange: (v: number) => void;
}) {
  return (
    <div className="flex items-center justify-between py-2">
      <span className="text-sm text-slate-700">{label}</span>
      <div className="flex items-center gap-3">
        <button
          type="button"
          onClick={() => onChange(Math.max(min, value - 1))}
          disabled={value <= min}
          className="w-7 h-7 rounded-full border border-slate-300 flex items-center justify-center disabled:opacity-40 hover:border-blue-500"
        >
          <Minus size={14} />
        </button>
        <span className="w-4 text-center text-sm font-medium">{value}</span>
        <button
          type="button"
          onClick={() => onChange(Math.min(max, value + 1))}
          disabled={value >= max}
          className="w-7 h-7 rounded-full border border-slate-300 flex items-center justify-center disabled:opacity-40 hover:border-blue-500"
        >
          <Plus size={14} />
        </button>
      </div>
    </div>
  );
}

export default function PaxSelector({ value, onChange }: PaxSelectorProps) {
  const [open, setOpen] = useState(false);
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onClick(e: MouseEvent) {
      if (ref.current && !ref.current.contains(e.target as Node)) setOpen(false);
    }
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  function setAdults(n: number) {
    onChange({ ...value, adults: n });
  }

  function addChild() {
    if (value.childAges.length >= 4) return;
    onChange({ ...value, childAges: [...value.childAges, 5] });
  }

  function removeChild() {
    onChange({ ...value, childAges: value.childAges.slice(0, -1) });
  }

  function setChildAge(i: number, age: number) {
    const ages = [...value.childAges];
    ages[i] = age;
    onChange({ ...value, childAges: ages });
  }

  const label =
    value.adults + value.childAges.length === 1
      ? '1 putnik'
      : `${value.adults + value.childAges.length} putnika` +
        (value.childAges.length > 0 ? ` (${value.childAges.length} dece)` : '');

  return (
    <div ref={ref} className="relative">
      <button
        type="button"
        onClick={() => setOpen((o) => !o)}
        className="w-full flex items-center gap-2 px-3 py-2.5 border border-slate-300 rounded-lg text-sm bg-white hover:border-blue-500 focus:outline-none focus:border-blue-500"
      >
        <Users size={16} className="text-slate-400 shrink-0" />
        <span className="flex-1 text-left text-slate-700">{label}</span>
      </button>

      {open && (
        <div className="absolute top-full mt-1 left-0 z-50 bg-white border border-slate-200 rounded-xl shadow-lg p-4 w-72">
          <Counter label="Odrasli" value={value.adults} min={1} max={8} onChange={setAdults} />

          <div className="border-t border-slate-100 my-2" />

          <div className="flex items-center justify-between py-2">
            <span className="text-sm text-slate-700">Deca (do 17 god.)</span>
            <div className="flex items-center gap-3">
              <button
                type="button"
                onClick={removeChild}
                disabled={value.childAges.length === 0}
                className="w-7 h-7 rounded-full border border-slate-300 flex items-center justify-center disabled:opacity-40 hover:border-blue-500"
              >
                <Minus size={14} />
              </button>
              <span className="w-4 text-center text-sm font-medium">
                {value.childAges.length}
              </span>
              <button
                type="button"
                onClick={addChild}
                disabled={value.childAges.length >= 4}
                className="w-7 h-7 rounded-full border border-slate-300 flex items-center justify-center disabled:opacity-40 hover:border-blue-500"
              >
                <Plus size={14} />
              </button>
            </div>
          </div>

          {value.childAges.length > 0 && (
            <div className="mt-2 space-y-2">
              {value.childAges.map((age, i) => (
                <div key={i} className="flex items-center justify-between">
                  <label className="text-sm text-slate-500">Dete {i + 1}</label>
                  <select
                    value={age}
                    onChange={(e) => setChildAge(i, Number(e.target.value))}
                    className="text-sm border border-slate-300 rounded px-2 py-1"
                  >
                    {Array.from({ length: 18 }, (_, n) => (
                      <option key={n} value={n}>
                        {n === 0 ? 'Beba (< 1 god.)' : `${n} god.`}
                      </option>
                    ))}
                  </select>
                </div>
              ))}
            </div>
          )}

          <button
            type="button"
            onClick={() => setOpen(false)}
            className="mt-4 w-full text-center text-sm text-blue-600 font-medium py-1"
          >
            Potvrdi
          </button>
        </div>
      )}
    </div>
  );
}
