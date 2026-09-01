
const http = require('http');
const fs = require('fs');
const path = require('path');
const { randomUUID, createHash } = require('crypto');

const port = process.env.PORT || 3000;

const users = [];
const tasks = [];
const sessions = new Map();

const hash = (value) =>
  createHash('sha256').update(value).digest('hex');

const send = (res, status, data) => {
  res.writeHead(status, {
    'Content-Type': 'application/json; charset=utf-8'
  });

  res.end(JSON.stringify(data));
};

const body = (req) =>
  new Promise((resolve, reject) => {
    let text = '';

    req.on('data', (c) => {
      text += c;
    });

    req.on('end', () => {
      try {
        resolve(text ? JSON.parse(text) : {});
      } catch {
        reject(new Error('Invalid JSON body'));
      }
    });
  });

const token = (req) =>
  (req.headers.authorization || '').replace(/^Bearer\s+/i, '');

const userFor = (req) =>
  users.find((u) => u.id === sessions.get(token(req)));

const safeUser = ({ id, name, email }) => ({
  id,
  name,
  email
});

const staticFile = (res, name) => {
  fs.readFile(
    path.join(__dirname, 'public', name),
    (err, file) => {
      if (err) {
        return send(res, 404, {
          error: 'Not found'
        });
      }

      let type = 'text/html';

      if (name.endsWith('.css')) {
        type = 'text/css';
      } else if (name.endsWith('.js')) {
        type = 'text/javascript';
      }

      res.writeHead(200, {
        'Content-Type': `${type}; charset=utf-8`
      });

      res.end(file);
    }
  );
};

http.createServer(async (req, res) => {

  /*
   * --------------------------------------------------
   * HANDLE /sample PREFIX
   * --------------------------------------------------
   *
   * ALB sends:
   *
   * /sample
   * /sample/
   * /sample/app.js
   * /sample/styles.css
   * /sample/api/health
   * /sample/api/tasks
   *
   * Convert them internally to:
   *
   * /
   * /
   * /app.js
   * /styles.css
   * /api/health
   * /api/tasks
   */

  const originalUrl = new URL(
    req.url,
    `http://${req.headers.host}`
  );

  let requestPath = originalUrl.pathname;

  if (
    requestPath === '/sample' ||
    requestPath.startsWith('/sample/')
  ) {
    requestPath =
      requestPath.replace(/^\/sample/, '') || '/';
  }

  const url = new URL(
    requestPath + originalUrl.search,
    `http://${req.headers.host}`
  );

  const parts = url.pathname
    .split('/')
    .filter(Boolean);


  /*
   * --------------------------------------------------
   * FRONTEND
   * --------------------------------------------------
   */

  if (
    req.method === 'GET' &&
    url.pathname === '/'
  ) {
    return staticFile(res, 'index.html');
  }

  if (
    req.method === 'GET' &&
    ['/app.js', '/styles.css'].includes(url.pathname)
  ) {
    return staticFile(
      res,
      url.pathname.slice(1)
    );
  }


  /*
   * --------------------------------------------------
   * HEALTH CHECK
   * --------------------------------------------------
   */

  if (
    req.method === 'GET' &&
    url.pathname === '/api/health'
  ) {
    return send(res, 200, {
      status: 'ok',
      time: new Date().toISOString()
    });
  }


  /*
   * --------------------------------------------------
   * REGISTER
   * --------------------------------------------------
   */

  if (
    req.method === 'POST' &&
    url.pathname === '/api/auth/register'
  ) {
    try {
      const {
        name,
        email,
        password
      } = await body(req);

      if (
        !name?.trim() ||
        !email?.trim() ||
        !password ||
        password.length < 6
      ) {
        return send(res, 400, {
          error:
            'Name, email, and a 6+ character password are required.'
        });
      }

      if (
        users.some(
          (u) =>
            u.email ===
            email.trim().toLowerCase()
        )
      ) {
        return send(res, 409, {
          error:
            'This email is already registered.'
        });
      }

      const user = {
        id: randomUUID(),
        name: name.trim(),
        email: email.trim().toLowerCase(),
        passwordHash: hash(password)
      };

      users.push(user);

      return send(res, 201, {
        message:
          'Account created. Please log in.',
        user: safeUser(user)
      });

    } catch (e) {
      return send(res, 400, {
        error: e.message
      });
    }
  }


  /*
   * --------------------------------------------------
   * LOGIN
   * --------------------------------------------------
   */

  if (
    req.method === 'POST' &&
    url.pathname === '/api/auth/login'
  ) {
    try {
      const {
        email,
        password
      } = await body(req);

      const user = users.find(
        (u) =>
          u.email ===
            email?.trim().toLowerCase() &&
          u.passwordHash ===
            hash(password || '')
      );

      if (!user) {
        return send(res, 401, {
          error:
            'Invalid email or password.'
        });
      }

      const sessionToken = randomUUID();

      sessions.set(
        sessionToken,
        user.id
      );

      return send(res, 200, {
        token: sessionToken,
        user: safeUser(user)
      });

    } catch (e) {
      return send(res, 400, {
        error: e.message
      });
    }
  }


  /*
   * --------------------------------------------------
   * LOGOUT
   * --------------------------------------------------
   */

  if (
    req.method === 'POST' &&
    url.pathname === '/api/auth/logout'
  ) {
    sessions.delete(token(req));

    return send(res, 200, {
      message: 'Logged out.'
    });
  }


  /*
   * --------------------------------------------------
   * AUTHENTICATION
   * --------------------------------------------------
   */

  const user = userFor(req);

  if (
    url.pathname.startsWith('/api/') &&
    !user
  ) {
    return send(res, 401, {
      error:
        'Please log in to access this API.'
    });
  }


  /*
   * --------------------------------------------------
   * CURRENT USER
   * --------------------------------------------------
   */

  if (
    req.method === 'GET' &&
    url.pathname === '/api/me'
  ) {
    return send(
      res,
      200,
      safeUser(user)
    );
  }


  /*
   * --------------------------------------------------
   * GET TASKS
   * --------------------------------------------------
   */

  if (
    req.method === 'GET' &&
    url.pathname === '/api/tasks'
  ) {
    return send(
      res,
      200,
      tasks.filter(
        (t) => t.userId === user.id
      )
    );
  }


  /*
   * --------------------------------------------------
   * CREATE TASK
   * --------------------------------------------------
   */

  if (
    req.method === 'POST' &&
    url.pathname === '/api/tasks'
  ) {
    try {
      const { title } = await body(req);

      if (!title?.trim()) {
        return send(res, 400, {
          error:
            'Task title is required.'
        });
      }

      const task = {
        id: randomUUID(),
        userId: user.id,
        title: title.trim(),
        completed: false,
        createdAt:
          new Date().toISOString()
      };

      tasks.unshift(task);

      return send(
        res,
        201,
        task
      );

    } catch (e) {
      return send(res, 400, {
        error: e.message
      });
    }
  }


  /*
   * --------------------------------------------------
   * UPDATE / DELETE TASK
   * --------------------------------------------------
   */

  const taskId = parts[2];

  const index = tasks.findIndex(
    (t) =>
      t.id === taskId &&
      t.userId === user.id
  );

  if (
    parts[0] === 'api' &&
    parts[1] === 'tasks' &&
    taskId
  ) {

    if (index < 0) {
      return send(res, 404, {
        error:
          'Task not found.'
      });
    }


    /*
     * PATCH TASK
     */

    if (req.method === 'PATCH') {
      try {
        const { completed } =
          await body(req);

        if (
          typeof completed === 'boolean'
        ) {
          tasks[index].completed =
            completed;
        }

        return send(
          res,
          200,
          tasks[index]
        );

      } catch (e) {
        return send(res, 400, {
          error: e.message
        });
      }
    }


    /*
     * DELETE TASK
     */

    if (req.method === 'DELETE') {
      return send(
        res,
        200,
        tasks.splice(index, 1)[0]
      );
    }
  }


  /*
   * --------------------------------------------------
   * UNKNOWN ROUTE
   * --------------------------------------------------
   */

  send(res, 404, {
    error: 'Route not found.'
  });

}).listen(
  port,
  '0.0.0.0',
  () => {
    console.log(
      `API Login Lab running on port ${port}`
    );
  }
);