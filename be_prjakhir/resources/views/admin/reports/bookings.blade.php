@extends('admin.layouts.admin')
@section('title', 'Laporan Booking')

@section('content')
{{-- Print styles --}}
<style>
    @media print {
        body { background: white !important; }
        .no-print { display: none !important; }
        .print-only { display: block !important; }
        header, aside, nav { display: none !important; }
        .main-content { margin: 0 !important; padding: 0 !important; }
        table { page-break-inside: auto; }
        tr { page-break-inside: avoid; }
    }
    .print-only { display: none; }
</style>

<div class="space-y-6">
    {{-- Header --}}
    <div class="flex flex-wrap items-center justify-between gap-3 no-print">
        <div>
            <h1 class="text-xl font-bold text-gray-900">📋 Laporan Booking</h1>
            <p class="text-sm text-gray-500">Filter dan cetak data booking.</p>
        </div>
        <div class="flex gap-2">
            <a href="{{ route('admin.reports.index') }}"
               class="px-4 py-2 text-sm rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50 transition">
                ← Kembali
            </a>
            <button onclick="window.print()"
                    class="px-4 py-2 text-sm bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition flex items-center gap-2">
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
    <form method="GET" action="{{ route('admin.reports.bookings') }}"
          class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 no-print">
        <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Dari Tanggal</label>
                <input type="date" name="from" value="{{ request('from', $from->format('Y-m-d')) }}"
                       class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Sampai Tanggal</label>
                <input type="date" name="to" value="{{ request('to', $to->format('Y-m-d')) }}"
                       class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:outline-none">
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Tipe</label>
                <select name="type" class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:outline-none">
                    <option value="all"   {{ $type == 'all'   ? 'selected' : '' }}>Semua</option>
                    <option value="bus"   {{ $type == 'bus'   ? 'selected' : '' }}>Bus</option>
                    <option value="train" {{ $type == 'train' ? 'selected' : '' }}>Kereta</option>
                    <option value="hotel" {{ $type == 'hotel' ? 'selected' : '' }}>Hotel</option>
                </select>
            </div>
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Status</label>
                <select name="status" class="w-full border border-gray-300 rounded-lg px-3 py-2 text-sm focus:ring-2 focus:ring-blue-500 focus:outline-none">
                    <option value="all"     {{ $status == 'all'     ? 'selected' : '' }}>Semua</option>
                    <option value="pending" {{ $status == 'pending' ? 'selected' : '' }}>Pending</option>
                    <option value="paid"    {{ $status == 'paid'    ? 'selected' : '' }}>Paid</option>
                    <option value="cancel"  {{ $status == 'cancel'  ? 'selected' : '' }}>Cancel</option>
                </select>
            </div>
        </div>
        <div class="mt-3 flex gap-2">
            <button type="submit"
                    class="px-5 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                Tampilkan
            </button>
            <a href="{{ route('admin.reports.bookings') }}"
               class="px-5 py-2 border border-gray-300 text-gray-600 rounded-lg text-sm hover:bg-gray-50 transition">
                Reset
            </a>
        </div>
    </form>

    {{-- Print Header --}}
    <div class="print-only text-center mb-4">
        <h1 class="text-2xl font-bold">LAPORAN BOOKING — MyTrip</h1>
        <p class="text-sm text-gray-600">
            Periode: {{ $from->format('d M Y') }} s/d {{ $to->format('d M Y') }}
            @if($type !== 'all') | Tipe: {{ strtoupper($type) }} @endif
            @if($status !== 'all') | Status: {{ ucfirst($status) }} @endif
        </p>
        <p class="text-xs text-gray-500">Dicetak pada: {{ now()->format('d M Y H:i') }}</p>
        <hr class="my-2">
    </div>

    {{-- Ringkasan Statistik --}}
    <div class="grid grid-cols-2 sm:grid-cols-4 gap-4">
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Total Booking</p>
            <p class="text-2xl font-bold text-gray-900">{{ $bookings->count() }}</p>
        </div>
        <div class="bg-white rounded-xl border border-emerald-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Paid</p>
            <p class="text-2xl font-bold text-emerald-600">{{ $countByStatus['paid'] ?? 0 }}</p>
        </div>
        <div class="bg-white rounded-xl border border-yellow-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Pending</p>
            <p class="text-2xl font-bold text-yellow-600">{{ $countByStatus['pending'] ?? 0 }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Total Nilai</p>
            <p class="text-lg font-bold text-blue-700">Rp {{ number_format($totalPaid, 0, ',', '.') }}</p>
            <p class="text-xs text-gray-400">(paid only)</p>
        </div>
    </div>

    {{-- Tabel --}}
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-600 border-b border-gray-200">
                    <tr>
                        <th class="px-4 py-3">No</th>
                        <th class="px-4 py-3">Kode Booking</th>
                        <th class="px-4 py-3">User</th>
                        <th class="px-4 py-3">Tipe</th>
                        <th class="px-4 py-3">Total Harga</th>
                        <th class="px-4 py-3">Status</th>
                        <th class="px-4 py-3">Metode Bayar</th>
                        <th class="px-4 py-3">Tanggal</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @forelse($bookings as $i => $b)
                    <tr class="hover:bg-gray-50">
                        <td class="px-4 py-3 text-gray-500">{{ $i + 1 }}</td>
                        <td class="px-4 py-3 font-mono font-semibold text-blue-700 text-xs">{{ $b->booking_code }}</td>
                        <td class="px-4 py-3">{{ $b->user->name ?? '-' }}</td>
                        <td class="px-4 py-3">
                            <span class="px-2 py-0.5 rounded-full text-xs font-medium
                                {{ $b->type == 'hotel' ? 'bg-amber-100 text-amber-700' :
                                   ($b->type == 'bus'   ? 'bg-sky-100 text-sky-700'   : 'bg-violet-100 text-violet-700') }}">
                                {{ strtoupper($b->type) }}
                            </span>
                        </td>
                        <td class="px-4 py-3 font-semibold">Rp {{ number_format($b->total_price, 0, ',', '.') }}</td>
                        <td class="px-4 py-3">
                            <span class="px-2 py-0.5 rounded-full text-xs font-medium
                                {{ $b->status == 'paid'    ? 'bg-emerald-100 text-emerald-700' :
                                   ($b->status == 'pending' ? 'bg-yellow-100 text-yellow-700'  : 'bg-red-100 text-red-600') }}">
                                {{ ucfirst($b->status) }}
                            </span>
                        </td>
                        <td class="px-4 py-3 text-xs text-gray-600">
                            {{ $b->payment ? $b->payment->paymentMethodLabel : '-' }}
                        </td>
                        <td class="px-4 py-3 text-xs text-gray-500">{{ $b->created_at->format('d M Y H:i') }}</td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="8" class="px-4 py-10 text-center text-gray-400">
                            Tidak ada data booking untuk periode ini.
                        </td>
                    </tr>
                    @endforelse
                </tbody>
                @if($bookings->count())
                <tfoot class="bg-gray-50 font-semibold border-t-2 border-gray-300">
                    <tr>
                        <td colspan="4" class="px-4 py-3 text-right text-gray-700">Total {{ $bookings->count() }} booking</td>
                        <td class="px-4 py-3 text-blue-700">Rp {{ number_format($totalAmount, 0, ',', '.') }}</td>
                        <td colspan="3" class="px-4 py-3 text-xs text-gray-500">
                            Paid: Rp {{ number_format($totalPaid, 0, ',', '.') }}
                        </td>
                    </tr>
                </tfoot>
                @endif
            </table>
        </div>
    </div>

    {{-- Print footer --}}
    <div class="print-only mt-8 text-xs text-gray-500 text-right">
        MyTrip Admin — Laporan digenerate otomatis oleh sistem
    </div>
</div>
@endsection
