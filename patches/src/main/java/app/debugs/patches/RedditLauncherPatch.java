package app.debugs.patches;

import app.morphe.patcher.patch.Compatibility;
import app.morphe.patcher.patch.PatchKt;
import app.morphe.patcher.patch.ResourcePatch;
import app.morphe.patcher.util.Document;
import kotlin.Unit;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;

public final class RedditLauncherPatch {
    private static final String ANDROID = "http://schemas.android.com/apk/res/android";
    public static final ResourcePatch redditLauncher = PatchKt.resourcePatch(
        "Debugs launcher label",
        "Labels the Reddit test build Reddit Debugs so it is distinguishable from stock.",
        false,
        patch -> {
            patch.compatibleWith(new Compatibility("com.reddit.frontpage.morphe"));
            patch.execute(context -> {
                try (Document manifest = context.document("AndroidManifest.xml")) {
                    NodeList applications = manifest.getElementsByTagName("application");
                    if (applications.getLength() != 1) {
                        throw new IllegalStateException("Expected exactly one application");
                    }
                    Element application = (Element) applications.item(0);
                    application.setAttributeNS(ANDROID, "android:label", "Reddit Debugs");
                }
                return Unit.INSTANCE;
            });
            return Unit.INSTANCE;
        }
    );

    public static ResourcePatch getRedditLauncher() {
        return redditLauncher;
    }

    private RedditLauncherPatch() {}
}
