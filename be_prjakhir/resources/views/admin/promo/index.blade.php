@extends('admin.layouts.admin')

@section('title', 'Kelola Promo')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">🎫 Kelola Promo</h1>
            <p class="text-sm text-gray-500 mt-1">Kelola kode promo dan diskon untuk aplikasi MyTrip.</p>
        </div>
        <a href="{{ route('admin.promo.create') }}" 
           class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
            </svg>
            Tambah Promo
        </a>
    </div>

    <!-- Alert Messages -->
    @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-50 border border-emerald-200 text-emerald-800 rounded-lg text-sm">
            {{ session('success') }}
        </div>
    @endif

    @if(session('error'))
        <div class="mb-6 p-4 bg-red-50 border border-red-200 text-red-800 rounded-lg text-sm">
            {{ session('error') }}
        </div>
    @endif

    <!-- Stats -->
    <div class="grid grid-cols-1 sm:grid-cols-4 gap-4 mb-6">
        <div class="bg-blue-50 rounded-lg p-4 border border-blue-100">
            <p class="text-sm text-blue-600">Total Promo</p>
            <p class="text-2xl font-bold text-blue-700">{{ $promos->total() }}</p>
        </div>
        <div class="bg-emerald-50 rounded-lg p-4 border border-emerald-100">
            <p class="text-sm text-emerald-600">Aktif</p>
            <p class="text-2xl font-bold text-emerald-700">{{ $promos->where('is_active', true)->count() }}</p>
        </div>
        <div class="bg-gray-50 rounded-lg p-4 border border-gray-100">
            <p class="text-sm text-gray-600">Non-Aktif</p>
            <p class="text-2xl font-bold text-gray-700">{{ $promos->where('is_active', false)->count() }}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
            <p class="text-sm text-purple-600">Kadaluarsa</p>
            <p class="text-2xl font-bold text-purple-700">{{ $promos->filter(function($p) { return $p->end_date < now(); })->count() }}</p>
        </div>
    </div>

    <!-- Filter -->
    <div class="mb-6">
        <form method="GET" action="{{ route('admin.promo.index') }}" class="flex flex-wrap gap-3">
            <div class="flex-1 min-w-[200px]">
                <input type="text" name="search" value="{{ request('search') }}" 
                       placeholder="Cari kode atau nama promo..." 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
            </div>
            <select name="status" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Status</option>
                <option value="active" {{ request('status') == 'active' ? 'selected' : '' }}>Aktif</option>
                <option value="inactive" {{ request('status') == 'inactive' ? 'selected' : '' }}>Non-Aktif</option>
            </select>
            <select name="target" class="rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
                <option value="">Semua Target</option>
                <option value="all" {{ request('target') == 'all' ? 'selected' : '' }}>Semua</option>
                <option value="bus" {{ request('target') == 'bus' ? 'selected' : '' }}>Bus</option>
                <option value="train" {{ request('target') == 'train' ? 'selected' : '' }}>Kereta</option>
                <option value="hotel" {{ request('target') == 'hotel' ? 'selected' : '' }}>Hotel</option>
            </select>
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition">
                Filter
            </button>
            <a href="{{ route('admin.promo.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-medium transition">
                Reset
            </a>
        </form>
    </div>

    <!-- Table -->
    <div class="overflow-x-auto rounded-lg border border-gray-200">
        <table class="w-full text-left border-collapse bg-white text-sm text-gray-500">
            <thead class="bg-gray-50 text-xs font-semibold uppercase text-gray-700 border-b border-gray-200">
                <tr>
                    <th class="px-6 py-4 text-center w-16">No</th>
                    <th class="px-6 py-4">Kode</th>
                    <th class="px-6 py-4">Nama</th>
                    <th class="px-6 py-4">Diskon</th>
                    <th class="px-6 py-4">Target</th>
                    <th class="px-6 py-4">Periode</th>
                    <th class="px-6 py-4 text-center">Penggunaan</th>
                    <th class="px-6 py-4 text-center">Status</th>
                    <th class="px-6 py-4 text-center w-48">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($promos as $index => $promo)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">
                        {{ $promos->firstItem() + $index }}
                    </td>
                    <td class="px-6 py-4 font-mono font-semibold text-blue-600">
                        {{ $promo->code }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        {{ $promo->name }}
                    </td>
                    <td class="px-6 py-4">
                        @if($promo->discount_type == 'percentage')
                            <span class="text-emerald-600 font-semibold">{{ $promo->discount_value }}%</span>
                            @if($promo->max_discount)
                                <span class="text-xs text-gray-400">(max Rp {{ number_format($promo->max_discount, 0, ',', '.') }})</span>
                            @endif
                        @else
                            <span class="text-emerald-600 font-semibold">Rp {{ number_format($promo->discount_value, 0, ',', '.') }}</span>
                        @endif
                    </td>
                    <td class="px-6 py-4">
                        <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold
                            {{ $promo->target_type == 'all' ? 'bg-gray-100 text-gray-700' : 
                               ($promo->target_type == 'bus' ? 'bg-sky-100 text-sky-700' : 
                               ($promo->target_type == 'train' ? 'bg-violet-100 text-violet-700' : 
                               'bg-amber-100 text-amber-700')) }}">
                            {{ $promo->target_type == 'all' ? 'Semua' : strtoupper($promo->target_type) }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-xs">
                        <div>{{ date('d/m/Y', strtotime($promo->start_date)) }}</div>
                        <div class="text-gray-400">→ {{ date('d/m/Y', strtotime($promo->end_date)) }}</div>
                    </td>
                    <td class="px-6 py-4 text-center">
                        <div class="text-sm font-medium">{{ $promo->usage_count }}</div>
                        @if($promo->usage_limit)
                            <div class="text-xs text-gray-400">/ {{ $promo->usage_limit }}</div>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-center">
                        @if($promo->is_active)
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-emerald-100 text-emerald-800 text-xs font-semibold">
                                Aktif
                            </span>
                        @else
                            <span class="inline-flex items-center px-2.5 py-1 rounded-full bg-red-100 text-red-800 text-xs font-semibold">
                                Non-Aktif
                            </span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-center">
                        <div class="flex items-center justify-center gap-1">
                            <a href="{{ route('admin.promo.show', $promo->id) }}" 
                               class="inline-flex items-center p-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-lg text-xs font-medium transition" 
                               title="Detail">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                            </a>
                            <a href="{{ route('admin.promo.edit', $promo->id) }}" 
                               class="inline-flex items-center p-1.5 bg-amber-50 text-amber-600 hover:bg-amber-100 rounded-lg text-xs font-medium transition" 
                               title="Edit">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                </svg>
                            </a>
                            {{-- Tombol Toggle --}}
                            <form action="{{ route('admin.promo.toggleActive', $promo->id) }}" method="POST" class="inline">
                                @csrf
                                <button type="submit" 
                                        class="inline-flex items-center p-1.5 {{ $promo->is_active ? 'bg-red-50 text-red-600 hover:bg-red-100' : 'bg-emerald-50 text-emerald-600 hover:bg-emerald-100' }} rounded-lg text-xs font-medium transition"
                                        title="{{ $promo->is_active ? 'Non-Aktifkan' : 'Aktifkan' }}">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v3m0 0v3m0-3h3m-3 0H9m12 0a9 9 0 11-18 0 9 9 0 0118 0z"></path>
                                    </svg>
                                </button>
                            </form>
                            <form action="{{ route('admin.promo.destroy', $promo->id) }}" method="POST" class="inline" 
                                  onsubmit="return confirm('Apakah Anda yakin ingin menghapus promo ini?')">
                                @csrf
                                @method('DELETE')
                                <button type="submit" 
                                        class="inline-flex items-center p-1.5 bg-red-50 text-red-600 hover:bg-red-100 rounded-lg text-xs font-medium transition"
                                        title="Hapus">
                                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"></path>
                                    </svg>
                                </button>
                            </form>
                        </div>
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="9" class="px-6 py-10 text-center text-gray-400">
                        Belum ada data promo. 
                        <a href="{{ route('admin.promo.create') }}" class="text-blue-600 hover:underline">Tambah promo sekarang</a>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="mt-6">
        {{ $promos->appends(request()->query())->links() }}
    </div>
</div>
@endsection