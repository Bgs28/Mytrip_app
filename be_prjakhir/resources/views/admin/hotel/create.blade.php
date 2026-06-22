@extends('admin.layouts.admin')

@section('title', 'Tambah Hotel')

@section('content')
<div class="max-w-3xl bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <h1 class="text-xl font-bold text-gray-900 mb-6">Tambah Hotel Baru</h1>

    <form action="{{ route('admin.hotels.store') }}" method="POST" enctype="multipart/form-data" class="space-y-5">
        @csrf
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Nama Hotel</label>
            <input type="text" name="name" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Nama penginapan/hotel" required>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Lokasi / Kota</label>
                <input type="text" name="location" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: Jakarta Selatan" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Harga Per Malam (Rp)</label>
                <input type="number" name="price" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: 550000" required>
            </div>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Rating Awal</label>
            <input type="number" step="0.1" min="0" max="5" name="rating" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: 4.5" required>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Deskripsi Hotel</label>
            <textarea name="description" rows="4" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Tulis fasilitas dan detail hotel..."></textarea>
        </div>

        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Foto Hotel</label>
            <input type="file" name="image" class="w-full text-sm text-gray-500 border border-gray-300 rounded-lg p-1 file:bg-blue-50 file:text-blue-700 file:px-4 file:py-2 file:border-0 file:rounded-md file:font-semibold">
        </div>

        <div class="flex items-center gap-3 pt-4 border-t">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-5 py-2 rounded-lg text-sm">Simpan Hotel</button>
            <a href="{{ route('admin.hotels.index') }}" class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium px-5 py-2 rounded-lg text-sm">Kembali</a>
        </div>
    </form>
</div>
@endsection