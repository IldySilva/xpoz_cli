import 'package:shelf/shelf.dart';

tunnelNotFound({domain}) {
  return Response.notFound(
    '''
  <!DOCTYPE html>
  <html lang="pt">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 | Not Found</title>
    <style>
      * {
        margin: 0;
        padding: 0;
        box-sizing: border-box;
      }
      
      body {
        font-family: 'SF Mono', 'Monaco', 'Inconsolata', 'Roboto Mono', monospace;
        background: #0a0a0a;
        color: #ffffff;
        height: 100vh;
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        overflow: hidden;
        position: relative;
      }
      
      body::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: 
          radial-gradient(circle at 20% 50%, rgba(120, 119, 198, 0.03) 0%, transparent 50%),
          radial-gradient(circle at 80% 20%, rgba(255, 119, 198, 0.03) 0%, transparent 50%),
          radial-gradient(circle at 40% 80%, rgba(120, 119, 255, 0.03) 0%, transparent 50%);
        pointer-events: none;
      }
      
      .container {
        text-align: center;
        z-index: 1;
      }
      
      .error-code {
        font-size: clamp(2.5rem, 8vw, 4rem);
        font-weight: 300;
        letter-spacing: 0.05em;
        margin-bottom: 0.5rem;
        color: #ffffff;
      }
      
      .divider {
        display: inline-block;
        width: 1px;
        height: 2rem;
        background: #666;
        margin: 0 1.5rem;
        vertical-align: middle;
      }
      
      .error-text {
        font-size: clamp(1rem, 3vw, 1.5rem);
        font-weight: 300;
        letter-spacing: 0.1em;
        color: #888;
        text-transform: uppercase;
      }
      
      
      @media (max-width: 768px) {
        .divider {
          height: 1.5rem;
          margin: 0 1rem;
        }
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="error-code">404</div>
      <div class="divider"></div>
      <div class="error-text">Not Found</div>
    </div>
  </body>
  </html>
  ''',
    headers: {'content-type': 'text/html'},
  );
}
