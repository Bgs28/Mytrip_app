@extends('admin.layouts.admin')

@section('title', 'Data Hotel')

@section('content')
<div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <!-- Header -->
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4 mb-6">
        <div>
            <h1 class="text-xl font-bold text-gray-900">🏨 Data Hotel</h1>
            <p class="text-sm text-gray-500 mt-1">Daftar hotel dan penginapan untuk aplikasi MyTrip</p>
        </div>
        <a href="{{ route('admin.hotels.create') }}" 
           class="inline-flex items-center px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white rounded-lg text-sm font-medium transition">
            <svg class="w-4 h-4 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4v16m8-8H4"></path>
            </svg>
            Tambah Hotel
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
            <p class="text-sm text-blue-600">Total Hotel</p>
            <p class="text-2xl font-bold text-blue-700">{{ $hotels->total() }}</p>
        </div>
        <div class="bg-emerald-50 rounded-lg p-4 border border-emerald-100">
            <p class="text-sm text-emerald-600">Rating Tertinggi</p>
            <p class="text-2xl font-bold text-emerald-700">{{ $hotels->max('rating') ?? 0 }}</p>
        </div>
        <div class="bg-purple-50 rounded-lg p-4 border border-purple-100">
            <p class="text-sm text-purple-600">Total Kamar</p>
            <p class="text-2xl font-bold text-purple-700">{{ $hotels->sum(function($h) { return $h->rooms->count(); }) }}</p>
        </div>
        <div class="bg-orange-50 rounded-lg p-4 border border-orange-100">
            <p class="text-sm text-orange-600">Harga Termurah</p>
            <p class="text-2xl font-bold text-orange-700">
                @php
                    $minPrice = $hotels->min(function($h) { return $h->min_price; }) ?? 0;
                @endphp
                Rp {{ number_format($minPrice, 0, ',', '.') }}
            </p>
        </div>
    </div>

    <!-- Search -->
    <div class="mb-6">
        <form method="GET" action="{{ route('admin.hotels.index') }}" class="flex flex-wrap gap-3">
            <div class="flex-1 min-w-[200px]">
                <input type="text" name="search" value="{{ request('search') }}" 
                       placeholder="Cari nama hotel atau lokasi..." 
                       class="w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-blue-500 focus:outline-none">
            </div>
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white px-4 py-2 rounded-lg text-sm font-medium transition">
                Cari
            </button>
            <a href="{{ route('admin.hotels.index') }}" class="bg-gray-200 hover:bg-gray-300 text-gray-700 px-4 py-2 rounded-lg text-sm font-medium transition">
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
                    <th class="px-6 py-4 text-center w-20">Foto</th>
                    <th class="px-6 py-4">Nama Hotel</th>
                    <th class="px-6 py-4">Lokasi</th>
                    <th class="px-6 py-4">Harga / Malam</th>
                    <th class="px-6 py-4 text-center">Rating</th>
                    <th class="px-6 py-4 text-center w-40">Aksi</th>
                </tr>
            </thead>
            <tbody class="divide-y divide-gray-200">
                @forelse($hotels as $index => $hotel)
                <tr class="hover:bg-gray-50 transition">
                    <td class="px-6 py-4 text-center font-medium text-gray-900">
                        {{ $hotels->firstItem() + $index }}
                    </td>
                    <td class="px-6 py-4 text-center">
                        @if($hotel->image)
                            <img src="{{ asset('storage/hotels/' . $hotel->image) }}" 
                                 alt="{{ $hotel->name }}" 
                                 class="w-12 h-12 object-cover rounded-lg border border-gray-200">
                        @else
                            <div class="w-12 h-12 bg-gray-100 rounded-lg border border-gray-200 flex items-center justify-center text-gray-400">
                                <svg class="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"></path>
                                </svg>
                            </div>
                        @endif
                    </td>
                    <td class="px-6 py-4 font-semibold text-gray-900">
                        {{ $hotel->name }}
                    </td>
                    <td class="px-6 py-4 text-gray-700">
                        <span class="inline-flex items-center gap-1">
                            <svg class="w-4 h-4 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"></path>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"></path>
                            </svg>
                            {{ $hotel->location }}
                        </span>
                    </td>
                    <td class="px-6 py-4 text-emerald-600 font-semibold">
                        {{ $hotel->price_range }}
                    </td>
                    <td class="px-6 py-4 text-center">
                        @if($hotel->rating > 0)
                            <div class="flex items-center justify-center gap-0.5">
                                @php
                                    $stars = $hotel->stars;
                                @endphp
                                @for($i = 0; $i < $stars['full']; $i++)
                                    <svg class="w-4 h-4 text-yellow-400 fill-current" viewBox="0 0 20 20">
                                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                                    </svg>
                                @endfor
                                @if($stars['half'] > 0)
                                    <svg class="w-4 h-4 text-yellow-400 fill-current" viewBox="0 0 20 20">
                                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z" clip-path="inset(0 50% 0 0)"/>
                                    </svg>
                                @endif
                                @for($i = 0; $i < $stars['empty']; $i++)
                                    <svg class="w-4 h-4 text-gray-300 fill-current" viewBox="0 0 20 20">
                                        <path d="M10 15l-5.878 3.09 1.123-6.545L.489 6.91l6.572-.955L10 0l2.939 5.955 6.572.955-4.756 4.635 1.123 6.545z"/>
                                    </svg>
                                @endfor
                                <span class="text-xs text-gray-500 ml-1">{{ number_format($hotel->rating, 1) }}</span>
                            </div>
                        @else
                            <span class="text-gray-400 text-xs">Belum ada rating</span>
                        @endif
                    </td>
                    <td class="px-6 py-4 text-center">
                        <div class="flex items-center justify-center gap-1">
                            <a href="{{ route('admin.hotels.show', $hotel->id) }}" 
                               class="inline-flex items-center p-1.5 bg-blue-50 text-blue-600 hover:bg-blue-100 rounded-lg text-xs font-medium transition" 
                               title="Detail">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"></path>
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"></path>
                                </svg>
                            </a>
                            <a href="{{ route('admin.hotels.edit', $hotel->id) }}" 
                               class="inline-flex items-center p-1.5 bg-amber-50 text-amber-600 hover:bg-amber-100 rounded-lg text-xs font-medium transition" 
                               title="Edit">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"></path>
                                </svg>
                            </a>
                            <form action="{{ route('admin.hotels.destroy', $hotel->id) }}" method="POST" class="inline" 
                                  onsubmit="return confirm('Apakah Anda yakin ingin menghapus hotel ini? Semua kamar akan terhapus.')">
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
                    <td colspan="7" class="px-6 py-10 text-center text-gray-400">
                        Belum ada data hotel. 
                        <a href="{{ route('admin.hotels.create') }}" class="text-blue-600 hover:underline">Tambah hotel sekarang</a>
                    </td>
                </tr>
                @endforelse
            </tbody>
        </table>
    </div>

    <!-- Pagination -->
    <div class="mt-6">
        {{ $hotels->appends(request()->query())->links() }}
    </div>
</div>
@endsection