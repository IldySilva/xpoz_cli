import 'package:shelf/shelf.dart' show Response;

healthCheck({domain, subdomain, host}) {
  return Response.ok(
    '''
      <html>
        <head><title>Teste Xpoz</title></head>
        <body style="font-family: sans-serif;">
          <h1>Tunnel OK</h1>
          <p>O subdomínio <strong>$subdomain.$domain</strong> está ativo e o servidor Dart respondeu com sucesso.</p>
          <p><strong>Host recebido:</strong> $host</p>
          
          <hr>
          <h3>🔌 Teste WebSocket:</h3>
          <button onclick="testWebSocket()">Testar WebSocket</button>
          <div id="wsStatus" style="margin-top: 10px; padding: 10px; border: 1px solid #ddd; background: #f9f9f9;"></div>
          
          <script>
            function testWebSocket() {
              const status = document.getElementById('wsStatus');
              status.innerHTML = '🔄 Conectando ao WebSocket...';
              
              const wsUrl = 'ws.$host/';
              console.log('Conectando a:', wsUrl);
              
              const ws = new WebSocket(wsUrl);
              
              ws.onopen = () => {
                status.innerHTML = '✅ WebSocket conectado com sucesso!<br>📡 Enviando ping...';
                ws.send(JSON.stringify({type: 'ping', timestamp: new Date().toISOString()}));
              };
              
              ws.onmessage = (event) => {
                try {
                  const data = JSON.parse(event.data);
                  status.innerHTML += '<br>📨 Resposta recebida: <code>' + JSON.stringify(data, null, 2) + '</code>';
                } catch (e) {
                  status.innerHTML += '<br>📨 Mensagem recebida: ' + event.data;
                }
              };
              
              ws.onerror = (error) => {
                console.error('WebSocket error:', error);
                status.innerHTML = '❌ Erro na conexão WebSocket. Verifique o console do navegador.';
              };
              
              ws.onclose = (event) => {
                status.innerHTML += '<br>🔌 Conexão WebSocket fechada (código: ' + event.code + ')';
              };
              
              // Fechar conexão após 5 segundos
              setTimeout(() => {
                if (ws.readyState === WebSocket.OPEN) {
                  ws.close();
                  status.innerHTML += '<br>⏰ Conexão fechada automaticamente após 5 segundos';
                }
              }, 5000);
            }
          </script>
        </body>
      </html>
      ''',
    headers: {'content-type': 'text/html'},
  );
}
