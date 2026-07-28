<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\Hotel;
use App\Models\Bus;
use App\Models\Train;
use App\Models\Booking;
use App\Models\Payment;
use App\Models\Room;
use Illuminate\Support\Carbon;

class DashboardController extends Controller
{
    public function index()
    {
        $now   = Carbon::now();
        $month = $now->month;
        $year  = $now->year;

        // ── Statistik umum ──────────────────────────────────────────────
        $totalUsers    = User::where('role', 'user')->count();
        $totalHotels   = Hotel::count();
        $totalBuses    = Bus::count();
        $totalTrains   = Train::count();
        $totalBookings = Booking::count();

        // ── Booking bulan ini ────────────────────────────────────────────
        $bookingsThisMonth = Booking::whereMonth('created_at', $month)
            ->whereYear('created_at', $year)
            ->count();

        // ── Pendapatan (payment paid) ────────────────────────────────────
        $totalRevenue = Payment::where('status', 'paid')->sum('total_amount');
        $revenueThisMonth = Payment::where('status', 'paid')
            ->whereMonth('created_at', $month)
            ->whereYear('created_at', $year)
            ->sum('total_amount');

        // ── Status booking ───────────────────────────────────────────────
        $bookingPending  = Booking::where('status', 'pending')->count();
        $bookingPaid     = Booking::where('status', 'paid')->count();
        $bookingCancelled = Booking::where('status', 'cancel')->count();

        // ── Booking per tipe ─────────────────────────────────────────────
        $bookingByType = Booking::selectRaw('type, count(*) as total')
            ->groupBy('type')
            ->pluck('total', 'type');

        // ── Pendapatan per bulan (12 bulan terakhir) ─────────────────────
        $revenueMonthly = [];
        for ($i = 11; $i >= 0; $i--) {
            $d = $now->copy()->subMonths($i);
            $revenueMonthly[] = [
                'label'  => $d->format('M Y'),
                'amount' => (float) Payment::where('status', 'paid')
                    ->whereMonth('created_at', $d->month)
                    ->whereYear('created_at', $d->year)
                    ->sum('total_amount'),
            ];
        }

        // ── Booking 6 bulan terakhir ─────────────────────────────────────
        $bookingMonthly = [];
        for ($i = 5; $i >= 0; $i--) {
            $d = $now->copy()->subMonths($i);
            $bookingMonthly[] = [
                'label' => $d->format('M Y'),
                'total' => Booking::whereMonth('created_at', $d->month)
                    ->whereYear('created_at', $d->year)
                    ->count(),
            ];
        }

        // ── Pembayaran menunggu verifikasi ───────────────────────────────
        $pendingPayments = Payment::with('booking.user')
            ->where('status', 'pending')
            ->whereNotNull('proof_of_payment')
            ->latest()
            ->take(5)
            ->get();

        // ── Booking terbaru ──────────────────────────────────────────────
        $recentBookings = Booking::with('user')
            ->latest()
            ->take(8)
            ->get();

        // ── Hotel dengan kamar terbanyak ─────────────────────────────────
        $topHotels = Hotel::withCount('rooms')
            ->orderByDesc('rooms_count')
            ->take(5)
            ->get();

        return view('admin.dashboard', compact(
            'totalUsers', 'totalHotels', 'totalBuses', 'totalTrains',
            'totalBookings', 'bookingsThisMonth',
            'totalRevenue', 'revenueThisMonth',
            'bookingPending', 'bookingPaid', 'bookingCancelled',
            'bookingByType', 'revenueMonthly', 'bookingMonthly',
            'pendingPayments', 'recentBookings', 'topHotels'
        ));
    }
}
