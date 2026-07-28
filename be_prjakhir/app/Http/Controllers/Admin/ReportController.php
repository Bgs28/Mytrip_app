<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Payment;
use App\Models\User;
use App\Models\Hotel;
use App\Models\Bus;
use App\Models\Train;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;

class ReportController extends Controller
{
    // Halaman pilih laporan
    public function index()
    {
        return view('admin.reports.index');
    }

    // Laporan Semua Booking dengan filter tanggal & tipe
    public function bookings(Request $request)
    {
        $from   = $request->filled('from')   ? Carbon::parse($request->from)->startOfDay()   : Carbon::now()->startOfMonth();
        $to     = $request->filled('to')     ? Carbon::parse($request->to)->endOfDay()       : Carbon::now()->endOfDay();
        $type   = $request->input('type', 'all');
        $status = $request->input('status', 'all');

        $query = Booking::with(['user', 'payment'])
            ->whereBetween('created_at', [$from, $to]);

        if ($type !== 'all') {
            $query->where('type', $type);
        }
        if ($status !== 'all') {
            $query->where('status', $status);
        }

        $bookings     = $query->latest()->get();
        $totalAmount  = $bookings->sum('total_price');
        $totalPaid    = $bookings->where('status', 'paid')->sum('total_price');
        $countByType  = $bookings->groupBy('type')->map->count();
        $countByStatus = $bookings->groupBy('status')->map->count();

        return view('admin.reports.bookings', compact(
            'bookings', 'from', 'to', 'type', 'status',
            'totalAmount', 'totalPaid', 'countByType', 'countByStatus'
        ));
    }

    // Laporan Pendapatan (hanya payment paid)
    public function revenue(Request $request)
    {
        $from = $request->filled('from') ? Carbon::parse($request->from)->startOfDay() : Carbon::now()->startOfMonth();
        $to   = $request->filled('to')   ? Carbon::parse($request->to)->endOfDay()     : Carbon::now()->endOfDay();
        $type = $request->input('type', 'all');

        $query = Payment::with(['booking.user'])
            ->where('status', 'paid')
            ->whereBetween('paid_at', [$from, $to]);

        $payments     = $query->latest('paid_at')->get();
        $totalRevenue = $payments->sum('total_amount');
        $totalDiscount = $payments->sum('discount_amount');
        $totalBase    = $payments->sum('base_amount');
        $countByMethod = $payments->groupBy('payment_method')->map->count();

        // Pendapatan per tipe booking
        $revenueByType = [];
        foreach ($payments as $p) {
            $t = $p->booking->type ?? 'unknown';
            $revenueByType[$t] = ($revenueByType[$t] ?? 0) + $p->total_amount;
        }

        return view('admin.reports.revenue', compact(
            'payments', 'from', 'to',
            'totalRevenue', 'totalDiscount', 'totalBase',
            'countByMethod', 'revenueByType'
        ));
    }

    // Laporan Rekap Bulanan
    public function monthly(Request $request)
    {
        $year = $request->input('year', Carbon::now()->year);

        $months = [];
        for ($m = 1; $m <= 12; $m++) {
            $start = Carbon::create($year, $m, 1)->startOfMonth();
            $end   = Carbon::create($year, $m, 1)->endOfMonth();

            $totalBooking  = Booking::whereBetween('created_at', [$start, $end])->count();
            $paidBooking   = Booking::where('status', 'paid')->whereBetween('created_at', [$start, $end])->count();
            $cancelBooking = Booking::where('status', 'cancel')->whereBetween('created_at', [$start, $end])->count();
            $revenue       = Payment::where('status', 'paid')->whereBetween('paid_at', [$start, $end])->sum('total_amount');
            $newUsers      = User::where('role', 'user')->whereBetween('created_at', [$start, $end])->count();

            $months[] = [
                'month'         => $start->translatedFormat('F'),
                'month_num'     => $m,
                'total_booking' => $totalBooking,
                'paid'          => $paidBooking,
                'cancel'        => $cancelBooking,
                'revenue'       => (float) $revenue,
                'new_users'     => $newUsers,
            ];
        }

        $yearlyRevenue      = array_sum(array_column($months, 'revenue'));
        $yearlyBooking      = array_sum(array_column($months, 'total_booking'));
        $availableYears     = range(Carbon::now()->year, Carbon::now()->year - 4);

        return view('admin.reports.monthly', compact(
            'months', 'year', 'yearlyRevenue', 'yearlyBooking', 'availableYears'
        ));
    }
}
