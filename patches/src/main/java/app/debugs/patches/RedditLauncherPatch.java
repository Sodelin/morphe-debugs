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
        "Keeps the Reddit Debugs name when you select alternate launcher icons.",
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
                    NodeList aliases = application.getElementsByTagName("activity-alias");
                    for (int i = 0; i < aliases.getLength(); i++) {
                        Element alias = (Element) aliases.item(i);
                        NodeList categories = alias.getElementsByTagName("category");
                        for (int j = 0; j < categories.getLength(); j++) {
                            Element category = (Element) categories.item(j);
                            if ("android.intent.category.LAUNCHER".equals(category.getAttributeNS(ANDROID, "name"))) {
                                alias.setAttributeNS(ANDROID, "android:label", "Reddit Debugs");
                                break;
                            }
                        }
                    }
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
