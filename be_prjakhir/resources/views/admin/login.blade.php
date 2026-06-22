<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Login</title>
    <script src="https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4"></script>
</head>
<body class="bg-blue-50 flex min-h-screen items-center justify-center font-sans antialiased">

    <div class="w-full max-w-md bg-white p-8 rounded-2xl shadow-xl border border-blue-100">
        
        <div class="text-center mb-8">
            <h2 class="text-3xl font-bold text-blue-900 tracking-tight">Admin Login</h2>
            <p class="text-sm text-blue-500 mt-2">Silakan masuk untuk mengelola dashboard Anda</p>
        </div>

        @if(session('error'))
            <div class="mb-5 p-4 bg-red-50 border-l-4 border-red-500 rounded-r-lg text-sm text-red-700 flex items-center">
                <svg class="w-5 h-5 mr-2 shrink-0" fill="currentColor" viewBox="0 0 20 20">
                    <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path>
                </svg>
                <span>{{ session('error') }}</span>
            </div>
        @endif

        <form method="POST" action="/admin/login" class="space-y-5">
            @csrf

            <div>
                <label class="block text-xs font-semibold text-blue-900 uppercase tracking-wider mb-2">Alamat Email</label>
                <input 
                    type="email" 
                    name="email" 
                    placeholder="nama@email.com"
                    required
                    class="w-full px-4 py-3 bg-blue-50/50 border border-blue-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-gray-800 placeholder-blue-300"
                >
            </div>

            <div>
                <label class="block text-xs font-semibold text-blue-900 uppercase tracking-wider mb-2">Kata Sandi</label>
                <input 
                    type="password" 
                    name="password" 
                    placeholder="••••••••"
                    required
                    class="w-full px-4 py-3 bg-blue-50/50 border border-blue-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-all text-gray-800 placeholder-blue-300"
                >
            </div>

            <button class="w-full py-3 px-4 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-xl shadow-md shadow-blue-200 hover:shadow-lg transition-all transform active:scale-[0.98] cursor-pointer text-center">
                Masuk Ke Dashboard
            </button>
        </form>

    </div>

</body>
</html>