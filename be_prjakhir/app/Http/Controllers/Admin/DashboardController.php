<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Hotel;
use App\Models\Flight;
use App\Models\Booking;


class DashboardController extends Controller
{
    public function index()
    {
        return view('admin.dashboard', [
            'users' => User::count(),
            'hotels' => Hotel::count(),
            'flights' => Flight::count(),
            'bookings' => Booking::count(),
        ]);
    }
}
