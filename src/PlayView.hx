import h2d.col.Point;

enum State {
	WaitingForTouch;
	Playing;
	MissedBall;
	Dead;
}

class PlayView extends GameState {
	final playWidth = 9;
	final playHeight = 16;

	final paddle = new h2d.Graphics();
	final paddleWidth = 2;
	final paddleHeight = 0.5;

	final ball = new h2d.Graphics();
	final ballSize = 0.5;
	var ballVel = new Point();

	final wallSize = 0.5;

	var state = WaitingForTouch;

	final pointsText = new Gui.Text("");
	var points = 0;

	final resetText = new Gui.Text("");
	final resetInteractive = new h2d.Interactive(0, 0);

	override function init() {
		pointsText.textColor = 0xffffff;
		pointsText.x = width * 0.05;
		pointsText.y = width * 0.02 + HerbalTeaApp.cutout.top;

		this.addChild(pointsText);

		resetText.text = "reset";
		resetText.textColor = 0xffffff;
		resetText.x = width - resetText.getBounds().width - width * 0.05;
		resetText.y = width * 0.02 + HerbalTeaApp.cutout.top;
		this.addChild(resetText);
		resetInteractive.width = resetText.getBounds().width;
		resetInteractive.height = resetText.getBounds().height;
		resetInteractive.onClick = e -> {
			setupGame();
		};
		resetText.addChild(resetInteractive);

		final gameArea = new h2d.Graphics(this);
		gameArea.y = height - width * playHeight / playWidth;
		gameArea.scale(width / playWidth);
		gameArea.beginFill(0x330000);
		gameArea.drawRect(0, 0, playWidth, playHeight);

		final wall = new h2d.Graphics(gameArea);
		wall.beginFill(0xffffff);
		wall.drawRect(0, 0, playWidth, wallSize);

		paddle.beginFill(0xffffff);
		paddle.drawRect(-paddleWidth / 2, 0, paddleWidth, paddleHeight);
		paddle.y = playHeight * 0.8;
		gameArea.addChild(paddle);

		ball.beginFill(0xffffff);
		ball.drawRect(-ballSize / 2, -ballSize / 2, ballSize, ballSize);
		gameArea.addChild(ball);

		setupGame();

		addEventListener(onEvent);
	}

	function setupGame() {
		resetText.visible = false;
		points = 0;
		paddle.x = playWidth / 2;
		ball.x = paddle.x;
		ball.y = paddle.y - ballSize / 2;
		state = WaitingForTouch;
	}

	function onEvent(event:hxd.Event) {
		switch (event.kind) {
			case EPush:
				if (state == WaitingForTouch) {
					state = Playing;
					setRandomBallVel();
				}
			default:
		}
		paddle.x = event.relX / width * playWidth;
	}

	function setRandomBallVel() {
		ballVel = new Point(0, -(10 + points));
		ballVel.rotate((Math.random() - 0.5) * Math.PI * 0.8);
	}

	override function update(dt:Float) {
		pointsText.text = "" + points;

		if (state == WaitingForTouch)
			return;

		ball.x += ballVel.x * dt;
		ball.y += ballVel.y * dt;

		if (ball.x - ballSize * 0.5 < 0) {
			ball.x = ballSize * 0.5;
			ballVel.x *= -1;
		}
		if (ball.x + ballSize * 0.5 > playWidth) {
			ball.x = playWidth - ballSize * 0.5;
			ballVel.x *= -1;
		}
		if (ball.y - ballSize * 0.5 < wallSize) {
			ball.y = wallSize + ballSize * 0.5;
			ballVel.y *= -1;
			points += 1;
		}
		if (ball.y + ballSize * 0.5 > paddle.y) {
			if (state == Playing && ball.x + ballSize > paddle.x - paddleWidth / 2 && ball.x - ballSize < paddle.x + paddleWidth / 2) {
				ball.y = paddle.y - ballSize * 0.5;
				setRandomBallVel();
			} else {
				state = MissedBall;
			}
		}
		if (ball.y - ballSize * 0.5 > playHeight) {
			state = Dead;
			resetText.visible = true;
		}
	}
}
