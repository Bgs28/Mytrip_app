@extends('admin.layouts.admin')
@section('title', 'Rekap Bulanan')

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
            <h1 class="text-xl font-bold text-gray-900">📅 Rekap Bulanan</h1>
            <p class="text-sm text-gray-500">Ringkasan booking, pendapatan, dan user baru per bulan.</p>
        </div>
        <div class="flex gap-2">
            <a href="{{ route('admin.reports.index') }}"
               class="px-4 py-2 text-sm rounded-lg border border-gray-300 text-gray-700 hover:bg-gray-50 transition">
                ← Kembali
            </a>
            <button onclick="window.print()"
                    class="px-4 py-2 text-sm bg-violet-600 text-white rounded-lg hover:bg-violet-700 transition flex items-center gap-2">
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

    {{-- Filter Tahun --}}
    <form method="GET" action="{{ route('admin.reports.monthly') }}"
          class="bg-white rounded-2xl border border-gray-100 shadow-sm p-5 no-print">
        <div class="flex items-end gap-4">
            <div>
                <label class="block text-xs font-semibold text-gray-600 mb-1">Tahun</label>
                <select name="year"
                        class="border border-gray-300 rounded-lg px-4 py-2 text-sm focus:ring-2 focus:ring-violet-500 focus:outline-none">
                    @foreach($availableYears as $y)
                    <option value="{{ $y }}" {{ $year == $y ? 'selected' : '' }}>{{ $y }}</option>
                    @endforeach
                </select>
            </div>
            <button type="submit"
                    class="px-5 py-2 bg-violet-600 text-white rounded-lg text-sm font-medium hover:bg-violet-700 transition">
                Tampilkan
            </button>
        </div>
    </form>

    {{-- Print Header --}}
    <div class="print-only text-center mb-4">
        <h1 class="text-2xl font-bold">REKAP BULANAN — MyTrip</h1>
        <p class="text-sm text-gray-600">Tahun: {{ $year }}</p>
        <p class="text-xs text-gray-500">Dicetak pada: {{ now()->format('d M Y H:i') }}</p>
        <hr class="my-2">
    </div>

    {{-- Ringkasan Tahun --}}
    <div class="grid grid-cols-2 sm:grid-cols-3 gap-4">
        <div class="bg-white rounded-xl border border-violet-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Total Booking {{ $year }}</p>
            <p class="text-2xl font-bold text-gray-900">{{ $yearlyBooking }}</p>
        </div>
        <div class="bg-white rounded-xl border border-emerald-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Total Pendapatan {{ $year }}</p>
            <p class="text-lg font-bold text-emerald-700">Rp {{ number_format($yearlyRevenue, 0, ',', '.') }}</p>
        </div>
        <div class="bg-white rounded-xl border border-gray-100 shadow-sm p-4 text-center">
            <p class="text-xs text-gray-500 uppercase font-medium">Rata-rata / Bulan</p>
            <p class="text-lg font-bold text-blue-700">
                Rp {{ number_format($yearlyRevenue / 12, 0, ',', '.') }}
            </p>
        </div>
    </div>

    {{-- Bar Chart Pendapatan --}}
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5 no-print">
        <p class="text-sm font-semibold text-gray-700 mb-4">Grafik Pendapatan Bulanan {{ $year }}</p>
        @php $maxRev = max(array_column($months, 'revenue') ?: [1]); $maxRev = max((float)$maxRev, 1); @endphp
        <div class="flex items-end gap-1 h-32">
            @foreach($months as $m)
            @php $pct = round($m['revenue'] / $maxRev * 100); @endphp
            <div class="flex-1 flex flex-col items-center gap-1 group">
                <div class="w-full bg-violet-500 rounded-t transition-all"
                     style="height: {{ max($pct, 2) }}%"
                     title="{{ $m['month'] }}: Rp {{ number_format($m['revenue'],0,',','.') }}">
                </div>
                <span class="text-[9px] text-gray-500">{{ substr($m['month'], 0, 3) }}</span>
            </div>
            @endforeach
        </div>
    </div>

    {{-- Tabel Rekap --}}
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full text-sm text-left">
                <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-600 border-b border-gray-200">
                    <tr>
                        <th class="px-4 py-3">Bulan</th>
                        <th class="px-4 py-3 text-center">Total Booking</th>
                        <th class="px-4 py-3 text-center">Paid</th>
                        <th class="px-4 py-3 text-center">Cancel</th>
                        <th class="px-4 py-3 text-center">Conv. Rate</th>
                        <th class="px-4 py-3 text-right">Pendapatan</th>
                        <th class="px-4 py-3 text-center">User Baru</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-gray-100">
                    @foreach($months as $m)
                    @php
                        $convRate = $m['total_booking'] > 0
                            ? round($m['paid'] / $m['total_booking'] * 100)
                            : 0;
                        $isCurrentMonth = $m['month_num'] == now()->month && $year == now()->year;
                    @endphp
                    <tr class="{{ $isCurrentMonth ? 'bg-violet-50' : 'hover:bg-gray-50' }}">
                        <td class="px-4 py-3 font-medium {{ $isCurrentMonth ? 'text-violet-700' : 'text-gray-800' }}">
                            {{ $m['month'] }} {{ $year }}
                            @if($isCurrentMonth)
                                <span class="ml-1 text-xs bg-violet-100 text-violet-700 px-2 py-0.5 rounded-full">Berjalan</span>
                            @endif
                        </td>
                        <td class="px-4 py-3 text-center font-semibold">{{ $m['total_booking'] }}</td>
                        <td class="px-4 py-3 text-center">
                            <span class="text-emerald-700 font-semibold">{{ $m['paid'] }}</span>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <span class="text-red-500 font-semibold">{{ $m['cancel'] }}</span>
                        </td>
                        <td class="px-4 py-3 text-center">
                            <div class="inline-flex items-center gap-1">
                                <div class="w-16 bg-gray-100 rounded-full h-1.5">
                                    <div class="bg-emerald-500 h-1.5 rounded-full" style="width: {{ $convRate }}%"></div>
                                </div>
                                <span class="text-xs text-gray-600">{{ $convRate }}%</span>
                            </div>
                        </td>
                        <td class="px-4 py-3 text-right font-semibold {{ $m['revenue'] > 0 ? 'text-emerald-700' : 'text-gray-400' }}">
                            {{ $m['revenue'] > 0 ? 'Rp ' . number_format($m['revenue'], 0, ',', '.') : '-' }}
                        </td>
                        <td class="px-4 py-3 text-center text-blue-700 font-semibold">
                            {{ $m['new_users'] > 0 ? '+' . $m['new_users'] : '-' }}
                        </td>
                    </tr>
                    @endforeach
                </tbody>
                <tfoot class="bg-gray-50 font-bold border-t-2 border-gray-300">
                    <tr>
                        <td class="px-4 py-3 text-gray-800">TOTAL {{ $year }}</td>
                        <td class="px-4 py-3 text-center">{{ $yearlyBooking }}</td>
                        <td class="px-4 py-3 text-center text-emerald-700">
                            {{ array_sum(array_column($months, 'paid')) }}
                        </td>
                        <td class="px-4 py-3 text-center text-red-500">
                            {{ array_sum(array_column($months, 'cancel')) }}
                        </td>
                        <td class="px-4 py-3 text-center text-gray-600">
                            @php
                                $totalPaid = array_sum(array_column($months, 'paid'));
                                $overallConv = $yearlyBooking > 0 ? round($totalPaid / $yearlyBooking * 100) : 0;
                            @endphp
                            {{ $overallConv }}%
                        </td>
                        <td class="px-4 py-3 text-right text-emerald-700">
                            Rp {{ number_format($yearlyRevenue, 0, ',', '.') }}
                        </td>
                        <td class="px-4 py-3 text-center text-blue-700">
                            +{{ array_sum(array_column($months, 'new_users')) }}
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

    <div class="print-only mt-8 text-xs text-gray-500 text-right">
        MyTrip Admin — Laporan digenerate otomatis oleh sistem
    </div>
</div>
@endsection
