<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Bus;


class BusController extends Controller
{

public function index()
{
    return response()->json([
        'data'=>Bus::all()
    ]);
}


public function show($id)
{
    return response()->json([
        'data'=>Bus::findOrFail($id)
    ]);
}

}