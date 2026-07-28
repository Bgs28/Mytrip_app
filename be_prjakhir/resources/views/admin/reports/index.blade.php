@extends('admin.layouts.admin')
@section('title', 'Laporan')

@section('content')
<div class="space-y-6">
    <div>
        <h1 class="text-2xl font-bold text-gray-900">📄 Laporan</h1>
        <p class="text-sm text-gray-500 mt-1">Pilih jenis laporan yang ingin dicetak atau diekspor.</p>
    </div>

    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">

        {{-- Laporan Booking --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition">
            <div class="w-12 h-12 rounded-xl bg-blue-50 flex items-center justify-center mb-4">
                <svg class="w-6 h-6 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2
                             M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2"/>
                </svg>
            </div>
            <h2 class="text-lg font-semibold text-gray-800 mb-1">Laporan Booking</h2>
            <p class="text-sm text-gray-500 mb-4">
                Seluruh data booking dengan filter tanggal, tipe (bus/kereta/hotel), dan status.
            </p>
            <a href="{{ route('admin.reports.bookings') }}"
               class="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg text-sm font-medium hover:bg-blue-700 transition">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                </svg>
                Buka Laporan
            </a>
        </div>

        {{-- Laporan Pendapatan --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition">
            <div class="w-12 h-12 rounded-xl bg-emerald-50 flex items-center justify-center mb-4">
                <svg class="w-6 h-6 text-emerald-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2
                             m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1
                             m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
            </div>
            <h2 class="text-lg font-semibold text-gray-800 mb-1">Laporan Pendapatan</h2>
            <p class="text-sm text-gray-500 mb-4">
                Rincian pembayaran yang sudah lunas (paid) beserta metode pembayaran dan diskon.
            </p>
            <a href="{{ route('admin.reports.revenue') }}"
               class="inline-flex items-center gap-2 px-4 py-2 bg-emerald-600 text-white rounded-lg text-sm font-medium hover:bg-emerald-700 transition">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                </svg>
                Buka Laporan
            </a>
        </div>

        {{-- Rekap Bulanan --}}
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 hover:shadow-md transition">
            <div class="w-12 h-12 rounded-xl bg-violet-50 flex items-center justify-center mb-4">
                <svg class="w-6 h-6 text-violet-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                          d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7
                             a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"/>
                </svg>
            </div>
            <h2 class="text-lg font-semibold text-gray-800 mb-1">Rekap Bulanan</h2>
            <p class="text-sm text-gray-500 mb-4">
                Ringkasan booking, pendapatan, dan user baru per bulan dalam satu tahun.
            </p>
            <a href="{{ route('admin.reports.monthly') }}"
               class="inline-flex items-center gap-2 px-4 py-2 bg-violet-600 text-white rounded-lg text-sm font-medium hover:bg-violet-700 transition">
                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                </svg>
                Buka Laporan
            </a>
        </div>

    </div>
</div>
@endsection
