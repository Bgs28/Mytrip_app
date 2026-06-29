@extends('admin.layouts.admin')

@section('title', 'Tambah Kereta')

@section('content')
<div class="max-w-3xl bg-white rounded-xl shadow-sm border border-gray-100 p-6">
    <h1 class="text-xl font-bold text-gray-900 mb-6">Tambah Jadwal Kereta Baru</h1>

    <form action="{{ route('admin.trains.store') }}" method="POST" class="space-y-5">
        @csrf
        <div>
            <label class="block text-sm font-medium text-gray-700 mb-1.5">Nama Kereta / Armada</label>
            <input type="text" name="train_name" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: Argo Bromo Anggrek" required>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Stasiun Asal (From)</label>
                <input type="text" name="from" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: Gambir (GMR)" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Stasiun Tujuan (Destination)</label>
                <input type="text" name="destination" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: Surabaya Pasar Turi (SBI)" required>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Jam Keberangkatan</label>
                <input type="time" name="departure_time" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Jam Kedatangan</label>
                <input type="time" name="arrival_time" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" required>
            </div>
        </div>

        <div class="grid grid-cols-1 md:grid-cols-2 gap-5">
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Harga Tiket (Rp)</label>
                <input type="number" name="price" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: 350000" required>
            </div>
            <div>
                <label class="block text-sm font-medium text-gray-700 mb-1.5">Jumlah Kursi Tersedia</label>
                <input type="number" name="seat" class="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 text-sm" placeholder="Contoh: 50" required>
            </div>
        </div>

        <div class="flex items-center gap-3 pt-4 border-t">
            <button type="submit" class="bg-blue-600 hover:bg-blue-700 text-white font-medium px-5 py-2 rounded-lg text-sm">Simpan Jadwal</button>
            <a href="{{ route('admin.trains.index') }}" class="bg-gray-100 hover:bg-gray-200 text-gray-700 font-medium px-5 py-2 rounded-lg text-sm">Kembali</a>
        </div>
    </form>
</div>
@endsection