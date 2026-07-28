@extends('admin.layouts.admin')
@section('title', 'Laporan Pendapatan')

@section('content')
<style>
    @media print {
        body { background: white !important; }
        .no-print { display: none !important; }
        .print-only { display: block !important; }
        header, aside, nav { display: none !important; }
        table { page-break-inside: auto; }
        tr { page-break-inside: avoid; }
    }
    .print-only { display: none; }
</style>

<div class="space-y-6">

    {{-- Header --}}
    <div class="flex flex-wrap items-center justify-between gap-3 no-print">
        <div>
            <h1 class="text-xl font-bold text-gray-900">💰 Laporan Pendapatan</h1>
            <p class="text-sm text-gray-500">Rincian pembayaran lunas beserta metode dan diskon.</p>
        </div>
        <div class="flex gap-2">
            <a href="{{ route('admin.reports.index') }}"
               class="px-4 py-2 text-sm rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50 transition">
                ← Kembali
            </a>
            <button onclick="window.print()"
                    class="px-4 py-2 text-sm bg-emerald-600 text-white rounded-lg hover:bg-emerald-700 transition flex items-center gap-2">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M17 17h2a2 2 0 002-2v-4a2 2 0 00-2-2H5a2 2 0 00-2 2v4a2 2 0 002 2h2
                             m2 4h6a2 2 0 002-2v-4a2 2 0 00-2-2H9a2 2 0 00-2 2v4a2 2 0 002 2zm8-12V5
                             a2 2 0 00-2-2H9a2 2 0 00-2 2v4h10z"/>
                </svg>
                Cetak
            </button>
        </div>
    </div>

    {{-- Filter --}}
    <form method="GET" action="{{ route('admin.reports.revenue') }}"
          class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 no-print">
        <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Dari Tanggal</label>
                <input type="date" name="from" value="{{ request('from', $from->format('Y-m-d')) }}"
                       class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-emerald-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Sampai Tanggal</label>
                <input type="date" name="to" value="{{ request('to', $to->format('Y-m-d')) }}"
                       class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-emerald-500 focus:outline-none">
            </div>
            <div class="flex items-end gap-2">
                <button type="submit"
                        class="flex-1 px-4 py-2 bg-emerald-600 text-white rounded-lg text-sm font-medium hover:bg-emerald-700 transition">
                    Tampilkan
                </button>
                <a href="{{ route('admin.reports.revenue') }}"
                   class="flex-1 px-4 py-2 text-center border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50 transition">
                    Reset
                </a>
            </div>
        </div>
    </form>

    {{-- Print Header --}}
    <div class="print-only text-center mb-4">
        <h1 class="text-2xl font-bold">LAPORAN PENDAPATAN — MyTrip</h1>
        <p class="text-sm text-gray-600">Periode: {{ $from->format('d M Y') }} s/d {{ $to->format('d M Y') }}</p>
        <p class="text-xs text-gray-500">Dicetak pada: {{ now()->format('d M Y H:i') }}</p>
        <hr class="my-2">
    </div>

    {{-- Kartu Ringkasan --}}
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-white rounded-xl border border-emerald-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Total Transaksi</p>
            <p class="text-2xl font-bold text-gray-900">{{ $payments->count() }}</p>
        </div>
        <div class="bg-white rounded-xl border border-emerald-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Pendapatan Bersih</p>
            <p class="text-lg font-bold text-emerald-700">Rp {{ number_format($totalRevenue, 0, ',', '.') }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Total Diskon</p>
            <p class="text-lg font-bold text-red-500">- Rp {{ number_format($totalDiscount, 0, ',', '.') }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Omzet Kotor</p>
            <p class="text-lg font-bold text-blue-700">Rp {{ number_format($totalBase, 0, ',', '.') }}</p>
        </div>
    </div>

    {{-- Ringkasan per Tipe & Metode --}}
    <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
        {{-- Per Tipe Booking --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-3">Pendapatan per Tipe</p>
            @php
                $typeIcons   = ['bus' => '🚌', 'train' => '🚆', 'hotel' => '🏨'];
                $maxTypeRev  = max(array_values($revenueByType) ?: [1]);
            @endphp
            @forelse($revenueByType as $t => $rev)
            <div class="mb-3">
                <div class="flex justify-between text-xs text-gray-600 mb-1">
                    <span>{{ $typeIcons[$t] ?? '📦' }} {{ ucfirst($t) }}</span>
                    <span class="font-semibold">Rp {{ number_format($rev, 0, ',', '.') }}</span>
                </div>
                <div class="w-full bg-gray-100 rounded-full h-2">
                    <div class="bg-emerald-500 h-2 rounded-full"
                         style="width: {{ round($rev / $maxTypeRev * 100) }}%"></div>
                </div>
            </div>
            @empty
            <p class="text-sm text-gray-400">Tidak ada data.</p>
            @endforelse
        </div>

        {{-- Per Metode Pembayaran --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
            <p class="text-sm font-semibold text-gray-700 mb-3">Transaksi per Metode Bayar</p>
            @php $maxMethod = max($countByMethod->values()->toArray() ?: [1]); @endphp
            @forelse($countByMethod as $method => $count)
            <div class="mb-3">
                <div class="flex justify-between text-xs text-gray-600 mb-1">
                    <span>{{ str_replace('_', ' ', ucwords($method, '_')) }}</span>
                    <span class="font-semibold">{{ $count }} transaksi</span>
                </div>
                <div class="w-full bg-gray-100 rounded-full h-2">
                    <div class="bg-blue-500 h-2 rounded-full"
                         style="width: {{ round($count / $maxMethod * 100) }}%"></div>
                </div>
            </div>
            @empty
            <p class="text-sm text-gray-400">Tidak ada data.</p>
            @endforelse
        </div>
    </div>

    {{-- Tabel Detail --}}
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-600 border-b border-gray-200">
                    <tr>
                        <th class="px-4 py-3">No</th>
                        <th class="px-4 py-3">Invoice</th>
                        <th class="px-4 py-3">Kode Booking</th>
                        <th class="px-4 py-3">User</th>
                        <th class="px-4 py-3">Tipe</th>
                        <th class="px-4 py-3">Omzet Kotor</th>
                        <th class="px-4 py-3">Diskon</th>
                        <th class="px-4 py-3">Pendapatan Bersih</th>
                        <th class="px-4 py-3">Metode</th>
                        <th class="px-4 py-3">Tgl Bayar</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($payments as $i => $pay)
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 text-gray-500">{{ $i + 1 }}</td>
                        <td class="px-4 py-3 font-mono text-xs font-semibold text-gray-700">{{ $pay->invoice_number }}</td>
                        <td class="px-4 py-3 font-mono text-xs text-blue-700 font-semibold">
                            {{ $pay->booking->booking_code ?? '-' }}
                        </td>
                        <td class="px-4 py-3">{{ $pay->booking->user->name ?? '-' }}</td>
                        <td class="px-4 py-3">
                            @php $t = $pay->booking->type ?? 'unknown'; @endphp
                            <span class="px-2 py-0.5 rounded-full text-xs font-medium
                                {{ $t == 'hotel' ? 'bg-amber-100 text-amber-700' :
                                   ($t == 'bus'   ? 'bg-sky-100 text-sky-700'   : 'bg-violet-100 text-violet-700') }}">
                                {{ strtoupper($t) }}
                            </span>
                        </td>
                        <td class="px-4 py-3">Rp {{ number_format($pay->base_amount, 0, ',', '.') }}</td>
                        <td class="px-4 py-3 text-red-500">
                            {{ $pay->discount_amount > 0 ? '- Rp ' . number_format($pay->discount_amount, 0, ',', '.') : '-' }}
                        </td>
                        <td class="px-4 py-3 font-semibold text-emerald-700">
                            Rp {{ number_format($pay->total_amount, 0, ',', '.') }}
                        </td>
                        <td class="px-4 py-3 text-xs text-gray-600">
                            {{ str_replace('_', ' ', ucwords($pay->payment_method, '_')) }}
                        </td>
                        <td class="px-4 py-3 text-xs text-gray-500">
                            {{ $pay->paid_at ? $pay->paid_at->format('d M Y H:i') : '-' }}
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="10" class="px-4 py-10 text-center text-gray-400">
                            Tidak ada data pendapatan untuk periode ini.
                        </td>
                    </tr>
                    @endforelse
                </tbody>
                @if($payments->count())
                <tfoot class="bg-gray-50 font-semibold border-t-2 border-gray-300">
                    <tr>
                        <td colspan="5" class="px-4 py-3 text-right text-gray-700">
                            Total {{ $payments->count() }} transaksi
                        </td>
                        <td class="px-4 py-3 text-blue-700">Rp {{ number_format($totalBase, 0, ',', '.') }}</td>
                        <td class="px-4 py-3 text-red-500">- Rp {{ number_format($totalDiscount, 0, ',', '.') }}</td>
                        <td class="px-4 py-3 text-emerald-700">Rp {{ number_format($totalRevenue, 0, ',', '.') }}</td>
                        <td colspan="2"></td>
                    </tr>
                </tfoot>
                @endif
            </table>
        </div>
    </div>

    <div class="print-only mt-8 text-xs text-gray-500 text-right">
        MyTrip Admin — Laporan digenerate otomatis oleh sistem
    </div>
</div>
@endsection
